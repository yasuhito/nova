require 'thread_pool'


class Dach
  def do_parallel list, &block
    @pool = ThreadPool.new
    list.each do | each |
      @pool.dispatch each, &block
    end
    @pool.shutdown
  end


  def teardown
    @in_teardown = true
    @pool.killall
    system 'pkill -9 -u dach000 -f dispatch.rb'

    do_parallel( @clusters ) do | each |
      @run[ each ].teardown
    end     
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
