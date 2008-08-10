#!/usr/bin/env ruby


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'clusters'
require 'cpu'
require 'net/telnet'


class Dacha
  def initialize cluster_name
    @cluster_name = cluster_name
  end


  def list
    cpus = []
    timeout = []
    connerr = []
    Clusters.list( @cluster_name )[ :list ].collect do | each |
      Thread.start do
        begin
          s = Net::Telnet.new( 'Host' => each, 'Port' => 3224, 'Timeout' => 1 )
          s.gets.split.each do | sload_avg |
            cpus << CPU.new( :name => each, :load_avg => sload_avg.to_i )
          end
          s.close
        rescue Timeout::Error
          timeout << each
        rescue Errno::ECONNREFUSED
          connerr << each
        rescue => e
          p e
        end
      end
    end.each do | each |
      each.join
    end
    # $stderr.puts "Timeout Error (#{ timeout.size } nodes): #{ timeout.sort.join( ' ' ) }" if timeout.size > 0
    # $stderr.puts "Connection Error (#{ connerr.size } nodes): #{ connerr.sort.join( ' ' ) }" if connerr.size > 0

    cpus
  end
end


if $0 == __FILE__
  /\A([a-zA-Z]+)\d+/=~ `hostname`
  nodes = Dacha.new( $1.to_sym ).list.collect do | each |
    each.name
  end.uniq
  ratio = nodes.size.to_f / Clusters.list( $1.to_sym )[ :list ].size * 100
  $stderr.puts "Available nodes (#{ nodes.size } nodes, #{ ratio.to_i } %): #{ nodes.join( ', ' ) }"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
