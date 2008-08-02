#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'rake'


# [FIXME] Temporally disable okubo cluster.
CLUSTERS = [ :pad, :kyushu, :hiro, :kyoto, :kobe, :suzuk, :keio, :imade, :chiba, :mirai, :hongo ] # :okubo


CLUSTERS.each do | each |
  c = Clusters.list( each )
  sh "scp dach000@#{ c[ :list ].first }.#{ c[ :domain ] }:/home/dach000/result/#{ each }.result results"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
