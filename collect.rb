#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'rake'


Clusters.all.each do | each |
  c = Clusters.list( each )

  dir = File.join( File.dirname( __FILE__ ), 'results', each.to_s )
  sh "rm -f #{ dir }/*"
  FileUtils.mkdir( dir ) unless FileTest.exists?( dir )

  # [TODO] if following scp failed, then try next node.
  sh "scp dach000@#{ c[ :list ].first }.#{ c[ :domain ] }:/home/dach000/result/*.result #{ dir }"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
