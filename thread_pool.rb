require 'dacha'
require 'log'
require 'thread'


class ThreadPool
  attr_reader :cpus
  attr_reader :nodes


  def initialize cluster_name, njobs
    @pool = []
    @njobs = njobs
    @dacha = Dacha.new( cluster_name )
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new

    @in_progress = 0
    @completed = 0
  end


  def update
    @cpus = @dacha.list.sort_by do | each |
      each.load_avg
    end
    @nodes = @cpus.collect do | each |
      each.name
    end.uniq
    @max_size = @cpus.size
  end


  def dispatch job
    Thread.new do
      # Wait for space in the pool
      @pool_mutex.synchronize do
        while @pool.size >= @max_size
          $stderr.puts "Pool is full; waiting to run #{ args.join( ',' ) }..." if $DEBUG
          # Sleep until some other thread calls @pool_cv.signal.
          @pool_cv.wait @pool_mutex
        end
        @in_progress += 1
      end

      begin
        node = @cpus.shift
        unless @pool.include?( Thread.current ) 
          @pool << Thread.current
        end

        start = Time.now
        puts "#{ Time.now.to_s } #{ status }: Job #{ job } started on #{ node.name }."
        yield node
      rescue => e
        exception node.name, job, e
        $stderr.puts Log.green( "Job #{ job } re-dispatching..." )
        retry
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from the pool.
          @pool.delete Thread.current
          # Enable node
          @cpus.push node
          # Signal the next waiting thread that there's a space in the pool.
          @pool_cv.signal
          # update counters
          @completed += 1
          @in_progress -= 1

          time = ( Time.now - start ).to_i
          puts "#{ Time.now.to_s } #{ status }: Job #{ job } on #{ node.name } finished in #{ time } seconds."
        end
      end
    end
  end
  

  def shutdown 
    @pool_mutex.synchronize do
      @pool_cv.wait( @pool_mutex ) until @pool.empty?
    end
  end


  ################################################################################
  private
  ################################################################################
  

  def status
    sprintf "[%2d in progress/%#{ @njobs.to_s.length }d completed/%#{ @njobs.to_s.length }d total]", @in_progress, @completed, @njobs
  end


  def exception node, job, exception
    $stderr.puts Log.pink( "Job #{ job } on #{ node } failed: #{ exception }" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
