require 'thread'


class ThreadPool
  def initialize cluster_name
    @pool = []
    @nodes = Nodes.list( cluster_name )
    @max_size = @nodes.size
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
  end


  def dispatch *args
    Thread.new do
      # Wait for space in the pool
      @pool_mutex.synchronize do
        while @pool.size >= @max_size
          $stderr.puts "Pool is full; waiting to run #{ args.join( ',' ) }..." if $DEBUG
          # Sleep until some other thread calls @pool_cv.signal.
          @pool_cv.wait @pool_mutex
        end
      end

      # [???]
      node = @nodes.pop
      @pool << { :node => node, :thread => Thread.current }
      begin
        yield node, *args
      rescue => e
        exception self, e, *args
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from the pool.
          @pool.delete( { :node => node, :thread => Thread.current } )
          # Enable node
          @nodes.unshift node
          # Signal the next waiting thread that there's a space in the pool.
          @pool_cv.signal
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
  

  def exception thread, exception, *original_args
    # Subclass this method to handle an exception within a thread.
    $stderr.puts "Exception in thread #{ thread }: #{ exception }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
