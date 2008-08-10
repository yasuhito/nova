#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
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
  if l.chomp != 'OK'
    puts l
  end
end
# [TODO] エラー処理: OK か ERROR かで、終了ステータスをちゃんと変える


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
