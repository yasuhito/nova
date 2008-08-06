#!/usr/bin/ruby -w


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'rake'
require 'shell'


$TRIAL_ID = nil


def run cluster, problem
  Popen3::Shell.open do | shell |
    cmd = "ssh dach000@#{ cluster[ :list ].first }.#{ cluster[ :domain ] } ruby /home/dach000/nova/nova.rb #{ problem }"

    shell.on_stdout do | line |
      $stdout.puts line
    end
    shell.on_stderr do | line |
      if /hongo/=~ cluster[ :list ].first and /Trial ID: (\S*)/=~ line
        $TRIAL_ID = $1
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
  sh "ssh dach000@hongo000.logos.ic.i.u-tokyo.ac.jp /home/dach911/dach_api/dach_api --check_ans #{ $TRIAL_ID } /home/dach000/nova/all.result"
elsif ARGV.size == 2
  run Clusters.list( ARGV[ 0 ].to_sym) , ARGV[ 1 ]
else
  $stderr.puts "start.rb [CLUSTER NAME]"
  exit 1
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
