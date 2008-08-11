#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
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


  def initialize problem, clusters
    @problem = problem
    @clusters = clusters

    @job = Hash.new( [] )
    @job_left = Hash.new( [] )
    @job_inprogress = Hash.new( [] )
    @job_done = Hash.new( [] )

    @node = Hash.new( [] )
    @node_left = Hash.new( [] )
    @node_inuse = Hash.new( [] )
    @novad = {}

    @pool = {}
    @clusters.each do | each |
      @pool[ each ] = ThreadPool.new
    end
  end


  def cleanup_results cluster
    msg "Cleaning up old *.result files for #{ cluster } cluster..."
    results( cluster ).each do | each |
      FileUtils.rm each, :verbose => true
    end
  end


  def cleanup cluster, novad_node
    msg "Cleaning up on #{ cluster }..."
    sh "ssh dach000@#{ novad_node } ruby /home/dach000/nova/quit.rb"
  end


  def start_novad cluster
    c = Clusters.list( cluster.to_sym )
    novad_node = [ c[ :list ].first, c[ :domain ] ].join( '.' )

    msg "Starting novad on #{ novad_node }"
    sh "ssh dach000@#{ novad_node } ruby /home/dach000/nova/novad.rb"

    msg "novad started on #{ novad_node }"
    @novad[ cluster ] = novad_node
  end


  def cleanup_processes cluster
    msg "Cleaning up dach processes on #{ cluster }..." 
    gxpc_init cluster
    gxpc_killall cluster
    gxpc_dachmon cluster
    gxpc_quit cluster
  end


  def get_job cluster
    msg "Getting job list on #{ cluster }..."
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        @job[ cluster ] = line.split( ' ' )
        @job_left[ cluster ] = @job[ cluster ].dup
      end
      shell.on_stderr do | line |
        $stderr.puts line
      end
      
      shell.on_success do
        msg "#{ cluster }: #{ @job[ cluster ].size } pairs."
      end
      shell.on_failure do
        raise "get_job on #{ cluster } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad[ cluster ] } ruby /home/dach000/nova/get_job.rb #{ @problem }"
    end
  end


  def get_nodes cluster
    msg "Getting node list on #{ cluster }..."

    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        @node[ cluster ] = line.split( ' ' )
        @node_left[ cluster ] = @node[ cluster ].dup
      end
      shell.on_stderr do | line |
        $stderr.puts line
      end

      shell.on_success do
        msg "#{ cluster }: #{ @node[ cluster ].size } nodes."
      end
      shell.on_failure do
        raise "get_nodes on #{ cluster } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad[ cluster ] } ruby /home/dach000/nova/get_nodes.rb"
    end
  end


  def finished? cluster
    @pool[ cluster ].synchronize do
      @job_left[ cluster ].empty? and @job_inprogress[ cluster ].empty?
    end
  end


  def continue cluster
    node, job = nil

    @pool[ cluster ].synchronize do
      if ( not @node_left[ cluster ].empty? ) and ( not @job_left[ cluster ].empty? )
        node = @node_left[ cluster ].shift
        @node_inuse[ cluster ] << node
        job = @job_left[ cluster ].shift
      end
    end

    if node and job
      @pool[ cluster ].dispatch( job ) do 
        dispatch cluster, node, job
      end
    else
      @pool[ cluster ].wait
    end
  end


  ################################################################################
  private
  ################################################################################


  def msg str
    puts str
  end


  def dispatch cluster, node, job
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
        @pool[ cluster ].synchronize do
          @node_left[ cluster ] << node
          @node_inuse[ cluster ].delete node
          @job_left[ cluster ].delete job
          @job_inprogress[ cluster ].delete job
          @job_done[ cluster ] << job
        end

        time = ( Time.now - start ).to_i
        msg "Job #{ job } on #{ node } finished successfully in #{ time }s."
        File.open( result_path( cluster, job, time ), 'w' ) do | f |
          r.each do | l |
            f.puts l
          end
        end
      end

      shell.on_failure do
        raise "job #{ job } on #{ node } failed"
      end

      @pool[ cluster ].synchronize do
        @job_inprogress[ cluster ] << job
      end
      shell.exec "ssh dach000@#{ @novad[ cluster ] } ruby /home/dach000/nova/dispatch.rb #{ node } #{ job }"
    end
  end


  def gxpc_init cluster
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc quit", :verbose => false
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc use ssh #{ cluster }", :verbose => false

    Popen3::Shell.open do | shell |
      shell.on_success do
        msg "gxpc explore on #{ cluster } succeeded."
      end
      shell.on_failure do
        raise "gxpc explore on #{ cluster } failed."
      end
      first = Clusters.list( cluster.to_sym )[ :list ].first.tr( cluster, '' )
      last = Clusters.list( cluster.to_sym )[ :list ].last.tr( cluster, '' )
      shell.exec "ssh dach000@#{ @novad[ cluster ] } gxpc explore #{ cluster }[[#{ first }-#{ last }]]"
    end
  end


  # [???] ほかに pkill すべきプロセスは？？
  # [???] pkill する順番は？
  def gxpc_killall cluster
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e pkill detect3", :verbose => false
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e pkill match2", :verbose => false
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e pkill mask3", :verbose => false
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e pkill sex", :verbose => false
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e pkill imsub3vp3", :verbose => false
  end


  def gxpc_dachmon cluster
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc e /home/dach000/nova/dachmon.rb", :verbose => false
  end


  def gxpc_quit cluster
    sh "ssh dach000@#{ @novad[ cluster ] } gxpc quit", :verbose => false
  end


  def results cluster
    Dir.glob File.join( result_dir( cluster ), '*.result' )
  end


  def result_path cluster, job, sec
    File.join result_dir( cluster ), "#{ job }.in#{ sec }s.result"
  end


  def result_dir cluster_name
    File.join File.dirname( __FILE__ ), 'results', cluster_name
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
