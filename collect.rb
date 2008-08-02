#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'rake'


Clusters.all.each do | each |
  c = Clusters.list( each )
  # [TODO] if following scp failed, then try next node.
  sh "scp dach000@#{ c[ :list ].first }.#{ c[ :domain ] }:/home/dach000/result/#{ each }.result results"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
