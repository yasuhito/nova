$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'novad'
require 'socket'


class NovadClient
  def initialize novad
    @novad = novad
  end


  def dispatch node, job
    s = TCPSocket.open( @novad, 3225 )
    s.puts "dispatch #{ node } #{ job }"

    r = []
    begin
      while l = s.gets
        case l
        when /^OK/
          s.close
          return r
        when /^ERROR/
          s.close
          raise "Dispatch error #{ node } #{ job }"
        else
          r << l.chomp
        end
      end
    rescue IOError
      return r
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
