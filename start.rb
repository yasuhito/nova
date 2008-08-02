#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'rake'


c = Clusters.list( ARGV[ 0 ].to_sym )
# [TODO] if following scp failed, then try next node.
sh "ssh dach000@#{ c[ :list ].first }.#{ c[ :domain ] } ruby /home/dach000/nova/nova.rb sample0"


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
