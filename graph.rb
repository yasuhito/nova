#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'gruff'


g = Gruff::Line.new
g.marker_font_size = 16
g.maximum_value = 100
g.minimum_value = 0

Clusters.all.each do | each |
  data = []
  dir = File.join( File.dirname( __FILE__ ), 'results', each.to_s )
  Dir.glob( "#{ dir }/*" ).each do | result |
    if /([^\/]+).in(\d+)s.result\Z/=~ result
      data << $2.to_i
    end
  end
  g.data each.to_s, data.sort
end

g.write File.join( File.dirname( __FILE__ ), 'intrigger.png' )


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
