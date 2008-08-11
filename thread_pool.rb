require 'log'
require 'thread'


class ThreadPool
  def initialize
    @pool = []
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
  end


  def dispatch *args
    Thread.new do
      begin
        @pool << Thread.current
        yield *args
      rescue => e
        $stderr.puts Log.pink( $!.to_str )
        $!.backtrace.each do | each |
          $stderr.puts each
        end
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
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
