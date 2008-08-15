#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'log'
require 'novad_client'
require 'rake'
require 'shell'
require 'thread_pool'


class Cluster
  attr_reader :clusters
  attr_reader :job
  attr_reader :job_done
  attr_reader :job_inprogress
  attr_reader :job_left
  attr_reader :node
  attr_reader :node_left
  attr_reader :novad
  attr_reader :trial_id


  @@list = {}


  def self.[] name
    @@list[ name ]
  end


  def initialize cluster, problem
    @cluster = cluster
    @problem = problem

    @job = []
    @job_left = []
    @job_inprogress = []
    @job_done = []

    @node = []
    @node_left = []

    @pool = ThreadPool.new

    c = Clusters.list( @cluster.to_sym )
    @domain = c[ :domain ]
    @novad = [ c[ :list ].first, @domain ].join( '.' )
    @novad_client = NovadClient.new( @novad )

    @@list[ cluster ] = self
  end


  def cleanup_results
    msg "[#{ @cluster }] Cleaning up old *.result files..."
    results.each do | each |
      FileUtils.rm each
    end
  end


  def teardown
    msg "[#{ @cluster }] Teardown..."
    @pool.killall
    gxpc_init
    cleanup_processes
    gxpc_quit
    begin
      sh "ssh dach000@#{ @novad } ruby /home/dach000/nova/quit.rb", :verbose => false
    rescue
      nil
    end
  end


  def shutdown
    @pool.shutdown
  end


  def start_novad
    msg "[#{ @cluster }] Starting novad..."
    sh "ssh dach000@#{ @novad } ruby /home/dach000/nova/novad.rb", :verbose => false
  end


  # [???] ほかに pkill すべきプロセスは？？
  # [???] pkill する順番は関係ある？
  def cleanup_processes
    msg "[#{ @cluster }] Cleaning up dach processes..."
    sh "ssh dach000@#{ @novad } ruby /home/dach000/nova/pkillnovad.rb", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 gfarm2fs", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 detect3", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 match2", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 mask3", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 sex", :verbose => false
    sh "ssh dach000@#{ @novad } gxpc e pkill -9 -u dach000 imsub3vp3", :verbose => false
  end


  def start_dachmon
    msg "[#{ @cluster }] Starting dachmon..."
    sh "ssh dach000@#{ @novad } gxpc e /home/dach000/nova/dachmon.rb", :verbose => false
  end


  def get_job
    msg "[#{ @cluster }] Getting job list..."
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        if /^ID (.*)/=~ line
          @trial_id = $1
        else
          @job = line.split( ' ' )
          @job_left = @job.dup
        end
      end
      shell.on_stderr do | line |
        $stderr.puts line
      end
      
      shell.on_failure do
        raise "get_job on #{ @cluster } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad } ruby /home/dach000/nova/get_job.rb #{ @problem }"
    end
  end


  def get_nodes
    msg "[#{ @cluster }] Getting node list..."
    
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        @node = line.split( ' ' ) * Clusters.list( @cluster.to_sym )[ :cpu_num ]
        @node_left = @node.dup
      end
      shell.on_stderr do | line |
        $stderr.puts line
      end

      shell.on_failure do
        raise "get_nodes on #{ @cluster } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad } ruby /home/dach000/nova/get_nodes.rb"
    end
  end


  def finished?
    @job_left.empty? and @job_inprogress.empty?
  end


  def continue
    node, job = nil

    @pool.synchronize do
      if ( not @node_left.empty? ) and ( not @job_left.empty? )
        while ( job = @job_left.shift ) do 
          if Jobs.assigned?( job )
            Log.warn "Job #{ job } already assigned. skipping..."
            @job_done << job
            DachCUI.show_status
          else
            break
          end
        end
        node = @node_left.shift
      end
    end

    if node and job
      @pool.dispatch( job ) do 
        dispatch node, job
      end
    else
      sleep 1
    end
  end


  def check_ans final_result
    sh "/home/dach911/dach_api/dach_api --check_ans #{ @trial_id } #{ final_result }"
  end


  def results
    Dir.glob File.join( result_dir, '*.result' )
  end


  def gxpc_init
    gxpc_quit
    sh "ssh dach000@#{ @novad } gxpc use ssh #{ @cluster }", :verbose => false

    Popen3::Shell.open do | shell |
      shell.on_failure do
        raise "[#{ @cluster }] gxpc explore failed!"
      end
      first = Clusters.list( @cluster.to_sym )[ :list ].first.tr( @cluster, '' )
      last = Clusters.list( @cluster.to_sym )[ :list ].last.tr( @cluster, '' )
      shell.exec "ssh dach000@#{ @novad } gxpc explore #{ @cluster }[[#{ first }-#{ last }]]"
    end
  end


  def gxpc_quit
    sh "ssh dach000@#{ @novad } gxpc quit", :verbose => false
  end


  ################################################################################
  private
  ################################################################################


  def msg str
    puts str
  end


  def dispatch node, job
    Jobs.assign job

    start = Time.now
    r = []

    begin
      Log.info "Starting job #{ job } on #{ node }..."
      @pool.synchronize do
        @job_inprogress << job
        DachCUI.show_status
      end

      r = @novad_client.dispatch( node, job )

      @pool.synchronize do
        @node_left << node
        @job_inprogress.delete job
        @job_done << job
        DachCUI.show_status
      end

      time = ( Time.now - start ).to_i
      Log.info "Job #{ job } on #{ node } finished successfully in #{ time }s."
      File.open( result_path( job, time ), 'w' ) do | f |
        r.each do | l |
          f.puts l
        end
      end
    rescue RuntimeError
      @pool.synchronize do
        Log.error "Job #{ job } on #{ node } failed"
        @node_left << node
        @job_inprogress.delete job
        @job_left << job
        Jobs.unassign job
        DachCUI.show_status
      end
    rescue
      Log.error $!.inspect
      $!.backtrace.each do | each |
        Log.error each
      end
      Jobs.unassign job
      @job_inprogress.delete job
      DachCUI.show_status
    end
  end


  def result_path job, sec
    File.join result_dir, "#{ job }.in#{ sec }s.result"
  end


  def result_dir
    File.join File.dirname( __FILE__ ), 'results', @cluster
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
