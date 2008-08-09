#!/usr/bin/ruby -w
#
# Usage:
#   ./dispatch.rb HOSTNAME FITS_ID
#
# Example:
#   ./dispatch.rb hongo000 006_31
#

require 'socket'


s = TCPSocket.open( 'localhost', 3225 )
s.puts "dispatch #{ ARGV[ 0 ] } #{ ARGV[ 1 ] }"
while l = s.gets
  puts l
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End: