require 'clusters'
require 'log'
require 'run'


class DachCUI
  def self.show_status
    system 'tput clear'
    system 'tput cup 0 0'

    Clusters.all.collect do | each |
      each.to_s
    end.each do | each |
      next if Run[ each ].nil?

      puts "[#{ each.capitalize } Cluster]"

      # CPU status
      inuse = Log.orange( '#' ) * Run[ each ].job_inprogress.size
      node_left = '#' * ( Run[ each ].node.size - Run[ each ].job_inprogress.size )
      puts sprintf( "   %3d CPU: %s", Run[ each ].node.size, inuse + node_left )

      # Job status
      done = Log.slate( '#' ) * Run[ each ].job_done.size
      inprogress = Log.green( '#' ) * Run[ each ].job_inprogress.size
      job_left = '#' * ( Run[ each ].job.size - Run[ each ].job_done.size - Run[ each ].job_inprogress.size )
      puts sprintf( "   %3d Job: %s", Run[ each ].job.size, done + inprogress + job_left )

      puts
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
