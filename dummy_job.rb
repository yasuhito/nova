$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'log'


if rand( 10 ) == 0
  $stderr.puts Log.pink( "#{ `hostname`.chomp } FAIL!" )
  exit 1
end

sleep rand( 600 )
exit 0


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
