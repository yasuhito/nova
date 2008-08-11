require 'log'
require 'thread'


class ThreadPool
  def initialize
    @pool = []
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
  end


  def dispatch job
    Thread.new do
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
    @pool_mutex.synchronize do
      @pool_cv.wait @pool_mutex
    end
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
