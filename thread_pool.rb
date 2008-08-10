require 'log'
require 'thread'


class ThreadPool
  def initialize max_size
    @pool = []
    @max_size = max_size
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
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
      end

      begin
        @pool << Thread.current
        yield
      rescue => e
        exception job, e
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from the pool.
          @pool.delete Thread.current
          # Signal the next waiting thread that there's a space in the pool.
          @pool_cv.signal
        end
      end
    end
  end

 
  def synchronize
    @pool_mutex.synchronize do
      yield
    end
  end


  def wait
    @pool_cv.wait @pool_mutex
  end


  def shutdown 
    @pool_mutex.synchronize do
      until @pool.empty?
        @pool_cv.wait @pool_mutex
      end
    end
  end


  ################################################################################
  private
  ################################################################################
  

  def exception job, exception
    $stderr.puts Log.pink( "Job #{ job } failed: #{ exception }" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
