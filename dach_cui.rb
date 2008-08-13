#!/usr/bin/env ruby


require 'rubygems'

require 'clusters'
require 'dach'
require 'log'
require 'rake'
require 'run'


class DachCUI < Dach
  def initialize problem, *clusters
    if clusters[ 0 ] == 'all'
      @clusters =  Clusters.all.collect do | each |
        each.to_s
      end
    else
      @clusters = clusters
    end

    @run = {}
    @clusters.each do | each |
      @run[ each ] = Run.new( problem, each )
    end

    @in_teardown = false
  end


  def start
    begin
      setup
      sleep 10
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


  def check_ans
    if @run[ 'hongo' ]
      results = @clusters.collect do | each |
        @run[ each ].results
      end.flatten

      sh "cat #{ results.join( ' ' ) } > #{ result }"
      @run[ 'hongo' ].check_ans result
    end
  end


  def result
    File.expand_path File.join( File.dirname( __FILE__ ), 'all.result' )
  end


  def setup
    do_parallel( @clusters ) do | each |
      @run[ each ].cleanup_results
      @run[ each ].gxpc_init
      @run[ each ].cleanup_processes
      @run[ each ].start_dachmon
      @run[ each ].gxpc_quit
      @run[ each ].start_novad
      @run[ each ].get_job
      @run[ each ].get_nodes
      puts "[#{ each }] *** Setup finished ***"
    end

    if @run[ 'hongo' ]
      sh "echo #{ @run[ 'hongo' ].trial_id } > #{ trial_id }"
    end
  end


  def trial_id
    File.expand_path File.join( File.dirname( __FILE__ ), 'trial_id' )
  end


  def run
    do_parallel( @clusters ) do | each |
      until @run[ each ].finished?
        @run[ each ].continue
        @pool.synchronize do
          show_status
        end
      end
    end
  end


  def show_status
    return if @in_teardown

    system 'tput clear'
    system 'tput cup 0 0'

    @clusters.each do | each |
      puts "[#{ each.capitalize } Cluster]"

      # CPU status
      inuse = Log.green( '#' ) * @run[ each ].node_inuse.size
      node_left = '#' * @run[ each ].node_left.size
      puts sprintf( "%10s: %s", 'CPU', inuse + node_left )

      # Job status
      done = Log.slate( '#' ) * @run[ each ].job_done.size
      inprogress = Log.green( '#' ) * @run[ each ].job_inprogress.size
      job_left = '#' * @run[ each ].job_left.size
      puts sprintf( "%10s: %s", 'Job', done + inprogress + job_left )

      puts
    end
  end
end


dach_cui = DachCUI.new( *ARGV )
dach_cui.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
