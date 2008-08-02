#!/usr/bin/env ruby


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'dach_api'
require 'jobs'
require 'shell'
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

    @pool.update

    print_nodes
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


  def print_nodes
    $stderr.puts "Available nodes (#{ @pool.nodes.size } nodes, #{ @pool.cpus.size } CPUs): #{ @pool.nodes.join( ', ' ) }"
  end


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
        $stderr.puts "#{ Time.now.to_s } #{ status }: Job #{ each.name } started on #{ node.name }."

        start = Time.now
        r = []
        Popen3::Shell.open do | shell |
          shell.on_stdout do | line |
            r << line
          end
          shell.on_stderr do | line |
            @stderr << line
            $stderr.puts line
          end
          shell.on_failure do
            raise %{Command "#{ command }" failed.\n#{ @stderr.join( "\n" )}}
          end
          
          cmd = "ssh #{ node.name } #{ each.to_cmd }"
          $stderr.puts cmd if $DEBUG
          shell.exec cmd
        end
        stop = Time.now

        time = ( stop - start ).to_i

        File.open( result_path( each, time ), 'w' ) do | f |
          r.each do | l |
            f.puts l
          end
        end

        @in_progress -= 1; @completed += 1
        $stderr.puts "#{ Time.now.to_s } #{ status }: Job #{ each.name } on #{ node.name } completed in #{ time } seconds."
      end
    end
  end


  def result_path job, sec
    File.join @dach_api.result_dir, "#{ job.name }.in#{ sec }s.result"
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
