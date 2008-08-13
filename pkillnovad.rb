#!/usr/bin/ruby -w


system 'pkill -9 -u dach000 -f dummy_job.rb'
system 'pkill -9 -u dach000 -f dach.sh'
system 'pkill -9 -u dach000 -f dispatch.rb'


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

