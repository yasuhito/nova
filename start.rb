#!/usr/bin/ruby -w


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'rubygems'

require 'clusters'
require 'rake'
require 'shell'


def run cluster
  Popen3::Shell.open do | shell |
    cmd = "ssh dach000@#{ cluster[ :list ].first }.#{ cluster[ :domain ] } ruby /home/dach000/nova/nova.rb sample0"

    shell.on_stdout do | line |
      $stdout.puts line
    end
    shell.on_stderr do | line |
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


if ARGV.size == 0
  Clusters.all.map do | each |
    Thread.start do
      run Clusters.list( each )
    end
  end.each do | each |
    each.join
  end

  sh 'ruby collect.rb'
  sh 'scp all.result dach@hongo000.logos.ic.i.u-tokyo.ac.jp:/home/dach000/nova/'
elsif ARGV.size == 1
  run Clusters.list( ARGV[ 0 ].to_sym )
else
  $stderr.puts "start.rb [CLUSTER NAME]"
  exit 1
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
