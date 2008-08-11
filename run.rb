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
  attr_reader :node
  attr_reader :novad
  attr_reader :job


  def initialize problem, clusters
    @problem = problem
    @clusters = clusters

    @job = Hash.new( [] )
    @node = Hash.new( [] )
    @novad = {}
    @pool = {}
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
        @job[ cluster ]  = line.split( ' ' )
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


  def dispatch_first
    @clusters.each do | c |
      @pool[ c ] = ThreadPool.new( @node[ c ].size )

      while ( not @node[ c ].empty? ) and ( not @job[ c ].empty? )
        n = @node[ c ].pop
        p = @job[ c ].pop

        msg "dispatch #{ p } to #{ n }"
        @pool[ c ].dispatch( p ) do 
          dispatch c, n, p
        end
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def main
    dispatch_first

    @pool.collect do | each |
      c = each[ 0 ]
      pool = each[ 1 ]
      Thread.start do
        pool.shutdown
#         pool.synchronize do
#           until @job[ c ].empty?
#             pool.wait
#             unless @node[ c ].empty?
#               n = @node[ c ].pop
#               p = @job[ c ].pop
#               pool.dispatch( p ) do 
#                 dispatch c, n, p
#               end
#             end
#           end
#        end
      end
    end.each do | each |
      each.join
    end
  end


  def msg str
    puts str
  end


  def show_status cluster
    $stderr.puts cluster
    $stderr.puts "[#{ @job[ cluster ].join( ', ' ) }]"
    $stderr.puts "[#{ @node[ cluster ].join( ', ' ) }]"
  end


  def dispatch cluster, node, job
    msg "Starting job #{ job } on #{ node }..."
    show_status cluster

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
        @node[ cluster ] << node
        show_status cluster

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


if __FILE__ == $0
  run = Run.new( ARGV )
  run.start
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
