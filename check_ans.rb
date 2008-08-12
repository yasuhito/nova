#!/usr/bin/env ruby


require 'rubygems'

require 'clusters'
require 'rake'


def trial_id
  path = File.expand_path( File.join( File.dirname( __FILE__ ), 'trial_id' ) )
  `cat #{ path }`.chomp
end


def final_result
  File.expand_path File.join( File.dirname( __FILE__ ), 'all.result' )
end


def results
  Clusters.all.collect do | each |
    result_dir = File.join( File.dirname( __FILE__ ), 'results', each.to_s )
    Dir.glob File.join( result_dir, '*.result' )
  end.flatten
end


$stderr.puts "Check Answer: #{ results.size } result files."
sh "cat #{ results.join( ' ' ) } > #{ final_result }", :verbose => false
sh "/home/dach911/dach_api/dach_api --check_ans #{ trial_id } #{ final_result }"



### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
