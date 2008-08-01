#!/usr/bin/ruby -w


require 'daemonize'
require 'nodes'
require 'socket'
require 'sys_cpu'
require 'tempfile'


include Daemonize


puts 'About to daemonize.'
fork do
  # daemonize
  log = Tempfile.new( 'dachmon.log' )

  loop do
    Nodes.list( :hongo ).collect do | each |
      Thread.start do
        begin
          sc = TCPSocket.open( each, 3224 )
          log.puts sc.gets
          log.flush
          sc.close
        rescue => e
          log.puts "Exception when connecting to #{ each }: #{ e.inspect }"
          log.flush
        end
      end
    end.each do | each |
      each.join
    end
  end

  socket = TCPServer.open( 3224 )
  loop do
    Thread.start( socket.accept ) do | ss |
      ss.puts Sys::CPU.load_avg[ 0 ]
      ss.close
    end
  end
#end


puts 'The subproces has become a daemon.'
puts "But I'm going to stick around for a while."
sleep 10
puts "Okay, now I'm done"

