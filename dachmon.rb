#!/usr/bin/ruby -w


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'daemonize'
require 'socket'
require 'sys_cpu'
require 'tempfile'


include Daemonize


fork do
  daemonize
  log = Tempfile.new( 'dachmon.log' )

  socket = TCPServer.open( 3224 )
  loop do
    Thread.start( socket.accept ) do | ss |
      ss.puts( ( [ Sys::CPU.load_avg[ 0 ] ] * Sys::CPU.processors.size ).join( ' ' ) )
      ss.close
    end
  end
end


sleep 10

