#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


require 'socket'


s = TCPSocket.open( 'localhost', 3225 )
s.puts "get_job #{ ARGV[ 0 ] }"
puts s.gets
puts s.gets
# [TODO] エラー処理: OK か ERROR かで、終了ステータスをちゃんと変える


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
