require 'thread_pool'


class Dach
  def do_parallel list, &block
    @pool = ThreadPool.new
    list.each do | each |
      @pool.dispatch each, &block
    end
    @pool.shutdown
  end


  def cleanup
    do_parallel( @clusters ) do | each |
      @run[ each ].cleanup
    end     
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
