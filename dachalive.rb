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
cluster_name = ARGV[ 0 ].to_sym


fork do
  daemonize
  loop do
    socket = TCPServer.open( 3225 )
    loop do
      Thread.start( socket.accept ) do | ss |
        dead = []
        alive = []
        Nodes.list( cluster_name ).collect do | each |
          Thread.start do
            begin
              sc = TCPSocket.open( each, 3224 )
              alive << each
              sc.close
            rescue => e
              dead << each
            end
          end
        end.each do | each |
          each.join
        end

        ss.puts alive.join( ',' )
        ss.close
      end
    end
  end
end


# puts 'The subproces has become a daemon.'
# puts "But I'm going to stick around for a while."
# sleep 10
# puts "Okay, now I'm done"

