require 'cluster'
require 'clusters'
require 'log'


class DachCUI
  def self.show_status
    system 'tput clear'
    system 'tput cup 0 0'

    Clusters.all.collect do | each |
      each.to_s
    end.each do | each |
      next if Cluster[ each ].nil?

      puts "[#{ each.capitalize } Cluster]"

      # CPU status
      inuse = Log.orange( '#' ) * Cluster[ each ].job_inprogress.size
      node_left = '#' * ( Cluster[ each ].node.size - Cluster[ each ].job_inprogress.size )
      puts sprintf( "   %3d CPU: %s", Cluster[ each ].node.size, inuse + node_left )

      # Job status
      done = Log.slate( '#' ) * Cluster[ each ].job_done.size
      inprogress = Log.green( '#' ) * Cluster[ each ].job_inprogress.size
      job_left = '#' * ( Cluster[ each ].job.size - Cluster[ each ].job_done.size - Cluster[ each ].job_inprogress.size )
      puts sprintf( "   %3d Job: %s", Cluster[ each ].job.size, done + inprogress + job_left )

      puts
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
