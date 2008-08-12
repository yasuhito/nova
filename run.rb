#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'log'
require 'rake'
require 'shell'
require 'thread_pool'


class Run
  attr_reader :clusters
  attr_reader :job
  attr_reader :job_done
  attr_reader :job_inprogress
  attr_reader :job_left
  attr_reader :node
  attr_reader :node_inuse
  attr_reader :node_left
  attr_reader :novad
  attr_reader :trial_id


  def initialize problem, cluster
    @problem = problem
    @cluster = cluster

    @job = []
    @job_left = []
    @job_inprogress = []
    @job_done = []

    @node = []
    @node_left = []
    @node_inuse = []

    @pool = ThreadPool.new
  end


  def cleanup_results
    msg "Cleaning up old *.result files for #{ @cluster } cluster..."
    results.each do | each |
      FileUtils.rm each, :verbose => true
    end
  end


  def cleanup
    msg "Cleaning up on #{ @cluster }..."
    sh "ssh dach000@#{ @novad } ruby /home/dach000/nova/quit.rb"
  end


  def start_novad
    c = Clusters.list( @cluster.to_sym )
    novad_node = [ c[ :list ].first, c[ :domain ] ].join( '.' )

    msg "Starting novad on #{ novad_node }"
    sh "ssh dach000@#{ novad_node } ruby /home/dach000/nova/novad.rb"

    msg "novad started on #{ novad_node }"
    @novad = novad_node
  end


  def cleanup_processes
    msg "Cleaning up dach processes on #{ @cluster }..." 
    gxpc_init
    gxpc_killall
    gxpc_dachmon
    gxpc_quit
  end


  def get_job
    msg "Getting job list on #{ @cluster }..."
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
      
      shell.on_success do
        msg "#{ @cluster }: #{ @job.size } pairs."
      end
      shell.on_failure do
        raise "get_job on #{ @cluster } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad } ruby /home/dach000/nova/get_job.rb #{ @problem }"
    end
  end


  def get_nodes
    msg "Getting node list on #{ @cluster }..."
    
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        @node = line.split( ' ' ) * Clusters.list( @cluster.to_sym )[ :cpu_num ]
        @node_left = @node.dup
      end
      shell.on_stderr do | line |
        $stderr.puts line
      end

      shell.on_success do
        msg "#{ @cluster }: #{ @node.size } nodes."
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
        node = @node_left.shift
        @node_inuse << node

        job = @job_left.shift
        @job_inprogress << job
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


  ################################################################################
  private
  ################################################################################


  def msg str
    puts str
  end


  def dispatch node, job
    msg "Starting job #{ job } on #{ node }..."

    start = Time.now
    r = []
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        r << line.chomp
      end

      shell.on_stderr do | line |
        $stderr.puts line
      end

      shell.on_success do
        @pool.synchronize do
          @node_left << node
          @node_inuse.delete node

          @job_inprogress.delete job
          @job_done << job
        end

        time = ( Time.now - start ).to_i
        msg "Job #{ job } on #{ node } finished successfully in #{ time }s."
        File.open( result_path( job, time ), 'w' ) do | f |
          r.each do | l |
            f.puts l
          end
        end
      end

      shell.on_failure do
        @pool.synchronize do
          $stderr.puts Log.pink( "job #{ job } on #{ node } failed" )

          @node_left << node
          @node_inuse.delete node

          @job_inprogress.delete job
          @job_left << job
        end
      end
      
      shell.exec "ssh dach000@#{ @novad } ruby /home/dach000/nova/dispatch.rb #{ node } #{ job }"
    end
  end


  def gxpc_init
    sh "ssh dach000@#{ @novad } gxpc quit"
    sh "ssh dach000@#{ @novad } gxpc use ssh #{ @cluster }"

    Popen3::Shell.open do | shell |
      shell.on_success do
        msg "gxpc explore on #{ @cluster } succeeded."
      end
      shell.on_failure do
        raise "gxpc explore on #{ @cluster } failed."
      end
      first = Clusters.list( @cluster.to_sym )[ :list ].first.tr( @cluster, '' )
      last = Clusters.list( @cluster.to_sym )[ :list ].last.tr( @cluster, '' )
      shell.exec "ssh dach000@#{ @novad } gxpc explore #{ @cluster }[[#{ first }-#{ last }]]"
    end
  end


  # [???] ほかに pkill すべきプロセスは？？
  # [???] pkill する順番は？
  def gxpc_killall
    sh "ssh dach000@#{ @novad } gxpc e pkill detect3"
    sh "ssh dach000@#{ @novad } gxpc e pkill match2"
    sh "ssh dach000@#{ @novad } gxpc e pkill mask3"
    sh "ssh dach000@#{ @novad } gxpc e pkill sex"
    sh "ssh dach000@#{ @novad } gxpc e pkill imsub3vp3"
  end


  def gxpc_dachmon
    sh "ssh dach000@#{ @novad } gxpc e /home/dach000/nova/dachmon.rb"
  end


  def gxpc_quit
    sh "ssh dach000@#{ @novad } gxpc quit"
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
