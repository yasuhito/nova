#!/usr/bin/ruby -w


require 'socket'


s = TCPSocket.open( 'localhost', 3225 )
s.puts "get_problem #{ ARGV[ 0 ] }"
puts s.gets
puts s.gets


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
