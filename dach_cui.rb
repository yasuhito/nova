#!/usr/bin/env ruby


require 'clusters'
require 'dach'
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


  def setup
    do_parallel( @clusters ) do | each |
      @run[ each ].cleanup_results
      @run[ each ].start_novad
      @run[ each ].cleanup_processes
      @run[ each ].get_job
      @run[ each ].get_nodes
      $stderr.puts "*** Setup finished on #{ each } ***"
    end      
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

      $stderr.puts sprintf( "%10s: %s", each, done + inprogress + left )
    end
    $stderr.puts
  end
end


dach_cui = DachCUI.new( *ARGV )
dach_cui.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
