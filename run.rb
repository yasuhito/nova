#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'rake'
require 'shell'
require 'thread_pool'


class Thread
  def self.map list, &block
    list.collect do | each |
      self.start do
        block.call each
      end
    end.each do | each |
      each.join
    end
  end
end


class Run
  attr_reader :clusters
  attr_reader :problem
  attr_reader :node


  def initialize clusters
    @clusters = clusters
    @problem = Hash.new( [] )
    @node = Hash.new( [] )
    @novad = {}
    @pool = {}
  end


  def cleanup_results
    msg 'Cleaning up old *.results...'
    results.each do | each |
      FileUtils.rm each
    end
  end


  def cleanup
    Thread.map( @novad ) do | each |
      msg "Cleaning up on #{ each[ 0 ] }..."
      sh "ssh dach000@#{ each[ 1 ] } ruby /home/dach000/nova/quit.rb", :verbose => false
    end
  end


  def start_novad
    Thread.map( @clusters ) do | each |
      c = Clusters.list( each.to_sym )
      novad_node = [ c[ :list ].first, c[ :domain ] ].join( '.' )
      begin
        msg "Starting novad on #{ novad_node }..."
        system "ssh dach000@#{ novad_node } ruby /home/dach000/nova/novad.rb"
        msg "novad started on #{ novad_node }."
      rescue
        msg "Failed to start novad on #{ novad_node }"
      end
      @novad[ each ] = novad_node
    end
  end


  def cleanup_processes
    Thread.map( @clusters ) do | each |
      msg "Cleaning up processes on #{ each }..." 
      gxpc_init each
      gxpc_killall each
      gxpc_dachmon each
      gxpc_quit each
    end
  end


  def get_problem
    Thread.map( @clusters ) do | each |
      msg "Getting problem list on #{ each }..."
      Popen3::Shell.open do | shell |
        shell.on_stdout do | line |
          @problem[ each ]  = line.split( ' ' )
        end
        shell.on_stderr do | line |
          $stderr.puts line
        end

        shell.on_success do
          msg "#{ each }: #{ @problem[ each ].size } pairs."
        end
        shell.on_failure do
          raise "get_problem on #{ each } failed"
        end
        
        shell.exec "ssh dach000@#{ @novad[ each ] } ruby /home/dach000/nova/get_problem.rb sample0"
      end
    end
  end


  def get_nodes
    Thread.map( @clusters ) do | each |
      msg "Getting node list on #{ each }..."

      Popen3::Shell.open do | shell |
        shell.on_stdout do | line |
          @node[ each ] = line.split( ' ' )
        end
        shell.on_stderr do | line |
          $stderr.puts line
        end

        shell.on_success do
          msg "#{ each }: #{ @node[ each ].size } nodes."
        end
        shell.on_failure do
          raise "get_nodes on #{ each } failed"
        end
        
        shell.exec "ssh dach000@#{ @novad[ each ] } ruby /home/dach000/nova/get_nodes.rb"
      end
    end
  end


  def dispatch_first
    @clusters.each do | c |
      @pool[ c ] = ThreadPool.new( @node[ c ].size )

      while ( not @node[ c ].empty? ) and ( not @problem[ c ].empty? )
        n = @node[ c ].pop
        p = @problem[ c ].pop

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
#           until @problem[ c ].empty?
#             pool.wait
#             unless @node[ c ].empty?
#               n = @node[ c ].pop
#               p = @problem[ c ].pop
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
    $stderr.puts "[#{ @problem[ cluster ].join( ', ' ) }]"
    $stderr.puts "[#{ @node[ cluster ].join( ', ' ) }]"
  end


  def dispatch cluster, node, problem
    msg "Starting problem #{ problem } on #{ node }..."
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
        msg "Problem #{ problem } on #{ node } finished successfully in #{ time }s."
        File.open( result_path( cluster, problem, time ), 'w' ) do | f |
          r.each do | l |
            f.puts l
          end
        end
      end

      shell.on_failure do
        raise "problem #{ problem } on #{ node } failed"
      end
      
      shell.exec "ssh dach000@#{ @novad[ cluster ] } ruby /home/dach000/nova/dispatch.rb #{ node } #{ problem }"
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


  def results
    @clusters.collect do | each |
      Dir.glob File.join( result_dir( each ), '*.result' )
    end.flatten
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
