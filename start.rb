#!/usr/bin/ruby -w
#
# Start dach jobs on cluster(s).
#
# Usage:
#   ruby start.rb PROBLEM_ID [CLUSTER_NAME...]
#


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'cluster'
require 'clusters'
require 'dach_cui'
require 'log'


class App
  def initialize problem, *clusters
    if clusters[ 0 ] == 'all'
      @clusters =  Clusters.all.collect do | each |
        each.to_s
      end
    else
      @clusters = clusters
    end

    @clusters.each do | each |
      Cluster.new each, problem
    end
  end


  def start
    begin
      setup
      run
      check_ans
    rescue Interrupt
      $stderr.puts 'Interrupted!'
      teardown
    rescue
      Log.error $!.to_str
      $!.backtrace.each do | each |
        Log.error each
      end
      teardown
    end
    puts 'OK'
  end


  ################################################################################
  private
  ################################################################################


  def run
    do_parallel( @clusters ) do | each |
      until Cluster[ each ].finished?
        Cluster[ each ].continue
      end
      Cluster[ each ].shutdown
    end
  end


  def setup
    do_parallel( @clusters ) do | each |
      Cluster[ each ].cleanup_results
      Cluster[ each ].gxpc_init
      Cluster[ each ].cleanup_processes
      Cluster[ each ].start_dachmon
      Cluster[ each ].gxpc_quit
      Cluster[ each ].start_novad
      Cluster[ each ].get_job
      Cluster[ each ].get_nodes
      puts "[#{ each }] *** Setup finished ***"
    end
    puts '****** All setup finished ******'

    if Cluster[ 'hongo' ]
      sh "echo #{ Cluster[ 'hongo' ].trial_id } > #{ trial_id }"
    end
  end


  def do_parallel list, &block
    @pool = ThreadPool.new
    list.each do | each |
      @pool.dispatch each, &block
    end
    @pool.shutdown
  end


  def teardown
    @pool.killall
    system 'pkill -9 -u dach000 -f dispatch.rb'

    do_parallel( @clusters ) do | each |
      Cluster[ each ].teardown
    end     
  end


  def check_ans
    if Cluster[ 'hongo' ]
      results = @clusters.collect do | each |
        Cluster[ each ].results
      end.flatten

      sh "cat #{ results.join( ' ' ) } > #{ result }", :verbose => false
      Cluster[ 'hongo' ].check_ans result
    end
  end


  def result
    File.expand_path File.join( File.dirname( __FILE__ ), 'all.result' )
  end


  def trial_id
    File.expand_path File.join( File.dirname( __FILE__ ), 'trial_id' )
  end
end


app = App.new( *ARGV )
app.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
