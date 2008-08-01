#!/usr/bin/ruby -w


require 'daemonize'
require 'nodes'
require 'socket'
require 'tempfile'


include Daemonize


if ARGV.size != 1
  $stderr.puts "Usage: dachalive.rb CLUSTER_NAME"
  exit
end
cluster_name = ARGV[ 0 ]


puts 'About to daemonize.'
fork do
  daemonize
  log = Tempfile.new( 'dachalive.log' )

  loop do
    Nodes.list( cluster_name ).collect do | each |
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
end


puts 'The subproces has become a daemon.'
puts "But I'm going to stick around for a while."
sleep 10
puts "Okay, now I'm done"

