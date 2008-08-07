#!/usr/bin/ruby -w
#
# Deploy dach programs to cluster nodes.
#
# Usage:
#   ruby deploy.rb
#   ruby deploy.rb CLUSTER_NAME
#


require 'rubygems'

require 'clusters'
require 'rake'


def scp name
  c = Clusters.list( name )
  sh "scp #{ File.dirname( __FILE__ ) }/*.rb dach000@#{ c[ :list ].first }.#{ c[ :domain ] }:/home/dach000/nova/"
end


if ARGV.size == 0
  Clusters.all.each do | each |
    scp each
  end
elsif ARGV.size == 1
  scp ARGV[ 0 ].to_sym
else
  $stderr.puts <<-MSG
Usage:
  ruby deploy.rb
  ruby deploy.rb CLUSTER_NAME
MSG
  exit 1
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
