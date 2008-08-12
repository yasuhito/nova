#!/usr/bin/env ruby


require 'rubygems'

require 'clusters'
require 'dach'
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
  end


  def start
    begin
      setup
      run
      check_ans
    rescue
      $stderr.puts $!.to_str
      $!.backtrace.each do | each |
        $stderr.puts each
      end
    ensure
      cleanup
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
      @run[ each ].start_novad
      @run[ each ].cleanup_processes
      @run[ each ].get_job
      @run[ each ].get_nodes
      puts "*** Setup finished on #{ each } ***"
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
        show_status
      end
    end
  end


  def show_status
    @clusters.each do | each |
      done = Log.slate( '#' ) * @run[ each ].job_done.size
      inprogress = Log.green( '#' ) * @run[ each ].job_inprogress.size
      left = '#' * @run[ each ].job_left.size

      puts sprintf( "%10s: %s", each, done + inprogress + left )
    end
    puts
  end
end


dach_cui = DachCUI.new( *ARGV )
dach_cui.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
