#!/usr/bin/ruby -w


require 'rubygems'

require 'clusters'
require 'rake'


def collect name
  c = Clusters.list( name )

  dir = File.join( File.dirname( __FILE__ ), 'results', name.to_s )
  sh "rm -f #{ dir }/*"
  FileUtils.mkdir( dir ) unless FileTest.exists?( dir )

  # [TODO] if following scp failed, then try next node.
  sh "scp dach000@#{ c[ :list ].first }.#{ c[ :domain ] }:/home/dach000/result/*.result #{ dir }"

  return File.join( dir, "#{ name }.result" )
end


def concat files
  sh "cat #{ files.join( ' ' ) } > all.result"
end


if ARGV.size == 0
  files = []
  Clusters.all.each do | each |
    files << collect( each )
  end
  concat files
elsif ARGV.size == 1
  collect ARGV[ 0 ].to_sym
else
  $stderr.puts "collect.rb [CLUSTER NAME]"
  exit 1
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
