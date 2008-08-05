require 'dacha'
require 'thread'


class ThreadPool
  attr_reader :cpus
  attr_reader :nodes


  def initialize cluster_name
    @pool = []
    @dacha = Dacha.new( cluster_name )
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
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

      node = @cpus.shift
      @pool << Thread.current
      begin
        yield node, *args
      rescue => e
        exception self, e, *args
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from the pool.
          @pool.delete Thread.current
          # Enable node
          @cpus.push node
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
