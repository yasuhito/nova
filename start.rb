#!/usr/bin/ruby -w
#
# Start dach jobs on cluster(s).
#
# Usage:
#   ruby start.rb
#   ruby start.rb CLUSTER_NAME
#


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'checkpoint'
require 'clusters'
require 'rake'
require 'shell'


def run cluster, problem
  Popen3::Shell.open do | shell |
    cmd = "ssh dach000@#{ cluster[ :list ].first }.#{ cluster[ :domain ] } ruby /home/dach000/nova/nova.rb #{ problem }"

    shell.on_stdout do | line |
      puts line
    end
    shell.on_stderr do | line |
      if /hongo/=~ cluster[ :list ].first and /Trial ID: (\S*)/=~ line
        Checkpoint.save :trial_id => $1
      end
      $stderr.puts line
    end
    shell.on_failure do
      raise %{Command "#{ cmd }" failed.}
    end

    # [TODO] if following scp failed, then try next node.  
    $stderr.puts cmd if $DEBUG
    shell.exec cmd
  end
end


if ARGV.size == 1
  Clusters.all.map do | each |
    Thread.start do
      run Clusters.list( each ), ARGV[ 0 ]
    end
  end.each do | each |
    each.join
  end

  sh 'ruby collect.rb'
  sh 'scp all.result dach000@hongo000.logos.ic.i.u-tokyo.ac.jp:/home/dach000/nova/'
  
  $stderr.puts "Checking answer..."
  sh "ssh dach000@hongo000.logos.ic.i.u-tokyo.ac.jp /home/dach911/dach_api/dach_api --check_ans #{ Checkpoint.load( :trial_id ) } /home/dach000/nova/all.result"
elsif ARGV.size == 2
  cluster_name = ARGV[ 0 ]
  run Clusters.list( cluster_name.to_sym ) , ARGV[ 1 ]

  puts
  puts Log.slate( "Collecting job results from #{ cluster_name } cluster..." )
  ruby "collect.rb #{ cluster_name }"

  puts
  puts Log.slate( "Copying back a final result file to hongo000..." )
  sh 'scp all.result dach000@hongo000.logos.ic.i.u-tokyo.ac.jp:/home/dach000/nova/'

  puts
  puts Log.slate( "Checking the final result...." )
  sh "ssh dach000@hongo000.logos.ic.i.u-tokyo.ac.jp /home/dach911/dach_api/dach_api --check_ans #{ Checkpoint.load( :trial_id ) } /home/dach000/nova/all.result"
else
  $stderr.puts <<-MSG
Usage:
  ruby start.rb
  ruby start.rb CLUSTER_NAME
MSG
  exit 1
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
