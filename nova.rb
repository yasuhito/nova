#!/usr/bin/env ruby


require 'dach_api'
require 'jobs'
require 'nodes'
require 'thread_pool'


class Nova
  def initialize
    @dach_api = DachAPI.new
    @pool = ThreadPool.new( cluster_name.to_sym )
    @in_progress = 0
    @completed = 0

    cleanup
  end


  def start problem_id
    @dach_api.get_problem problem_id

    $stderr.puts "Problem ID: #{ problem_id }"
    $stderr.puts "  Trial ID: #{ @dach_api.trial_id }"
    $stderr.puts "  Fits DIR: #{ @dach_api.fits_dir }"
    $stderr.puts

    dispatch
    @pool.shutdown

    $stderr.puts 
    concat_results

    $stderr.puts
    $stderr.puts "Check Answer:"
    @dach_api.check_ans result
  end


  ################################################################################
  private
  ################################################################################


  def cleanup
    results.each do | each |
      FileUtils.rm each
    end
  end


  def concat_results
    $stderr.puts "Result (#{ cluster_name } cluster): #{ result }"
    system "cat #{ results.join( ' ' ) } > #{ result }"
  end


  def result
    File.join @dach_api.result_dir, "#{ cluster_name }.result"
  end


  def results
    Dir.glob File.join( @dach_api.result_dir, '*.result' )
  end


  def cluster_name
    /\A([a-zA-Z]+)\d+/=~ `hostname`
    $1
  end


  def dispatch
    jobs.each do | each |
      @pool.dispatch do | node |
        @in_progress += 1
        $stderr.puts "#{ status }: Job #{ each.name } started on #{ node }."

        # [FIXME] use GXP ??
        cmd = "ssh #{ node } #{ each.to_cmd } > #{ job_result( each ) }"
        $stderr.puts cmd if $DEBUG
        system cmd

        @in_progress -= 1; @completed += 1
        $stderr.puts "#{ status }: Job #{ each.name } on #{ node } completed."
      end
    end
  end


  def job_result job
    File.join @dach_api.result_dir, "#{ job.name }.result"
  end


  def jobs
    Jobs.list @dach_api.fits_dir
  end


  def status
    dig = jobs.size.to_s.length
    sprintf "[%2d in progress/%#{ dig }d completed/%#{ dig }d total]", @in_progress, @completed, jobs.size
  end
end


raise "Usage: nova.rb problem_id" if ARGV.size != 1
Nova.new.start ARGV[ 0 ]


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
