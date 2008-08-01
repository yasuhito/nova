require 'cpu'
require 'net/telnet'
require 'nodes'


class Dacha
  def initialize cluster_name
    @cluster_name = cluster_name
  end


  def list
    $stderr.puts "Getting a list of available CPUs..."

    cpus = []
    timeout = []
    connerr = []
    Nodes.list( @cluster_name ).collect do | each |
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
    $stderr.puts "Timeout Error (#{ timeout.size } nodes): #{ timeout.sort.join( ' ' ) }" if timeout.size > 0
    $stderr.puts "Connection Error (#{ connerr.size } nodes): #{ connerr.sort.join( ' ' ) }" if connerr.size > 0

    cpus
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
