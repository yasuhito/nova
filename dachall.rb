#!/usr/bin/env ruby


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'dacha'
require 'rake'


Clusters.all.each do | each |
  cluster = Clusters.list( each )
  sh "ssh dach000@#{ cluster[ :list ].first }.#{ cluster[ :domain ] } ruby /home/dach000/nova/dacha.rb"
  $stderr.puts
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
