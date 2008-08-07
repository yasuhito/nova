#!/usr/bin/env ruby


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'dach_api'
require 'jobs'
require 'log'
require 'shell'
require 'thread_pool'


class Nova
  def initialize
    @dach_api = DachAPI.new
    cleanup
  end


  def start problem_id
    @dach_api.get_problem problem_id
    $stderr.puts "Problem ID: #{ problem_id }"
    $stderr.puts "  Trial ID: #{ @dach_api.trial_id }"
    $stderr.puts "  Fits DIR: #{ @dach_api.fits_dir }"
    $stderr.puts

    @pool = ThreadPool.new( cluster_name.to_sym, jobs.size )
    @pool.update

    print_nodes
    $stderr.puts

    dispatch
    @pool.shutdown

    concat_results
  end


  ################################################################################
  private
  ################################################################################


  def print_nodes
    $stderr.puts "Available nodes (#{ @pool.nodes.size } nodes, #{ @pool.cpus.size } CPUs): #{ @pool.nodes.join( ', ' ) }"
  end


  def cleanup
    results.each do | each |
      FileUtils.rm each
    end
  end


  def concat_results
    puts "#{ Log.green( 'FINISHED' ) } (#{ cluster_name } cluster)"
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


  # [XXX] RETRY if failed to dispatch
  def dispatch
    jobs.each do | each |
      @pool.dispatch( each.name ) do | node |
        # cmd = "ssh #{ node.name } #{ each.to_cmd }"
        cmd = "ssh #{ node.name } sleep 20"

        r = []
        start = Time.now
        Popen3::Shell.open do | shell |
          shell.on_stdout do | line |
            r << line
          end
          shell.on_stderr do | line |
            $stderr.puts line
          end
          shell.on_failure do
            raise %{Command "#{ cmd }" failed.}
          end
          
          $stderr.puts cmd if $DEBUG
          shell.exec cmd

          File.open( result_path( each, ( Time.now - start ).to_i ), 'w' ) do | f |
            r.each do | l |
              f.puts l
            end
          end
        end
      end
    end
  end


  def result_path job, sec
    File.join @dach_api.result_dir, "#{ job.name }.in#{ sec }s.result"
  end


  def jobs
    Jobs.list @dach_api.fits_dir
  end
end


raise "Usage: nova.rb problem_id" if ARGV.size != 1
Nova.new.start ARGV[ 0 ]


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
