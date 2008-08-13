require 'cluster'
require 'clusters'
require 'log'


class DachCUI
  SCALE = 5


  def self.show_status
    system 'tput clear'
    system 'tput cup 0 0'

    Clusters.all.collect do | each |
      each.to_s
    end.each do | each |
      next if Cluster[ each ].nil?

      puts "[#{ each.capitalize } Cluster]"

      # CPU status
      cpu_all = Cluster[ each ].node.size
      cpu_inuse = Cluster[ each ].job_inprogress.size
      cpu_idle = ( Cluster[ each ].node.size - Cluster[ each ].job_inprogress.size )
      puts sprintf( "              CPU #{ cpu_status( cpu_inuse, cpu_idle ) }: %s", Log.orange( '#' ) * ( cpu_inuse / SCALE ) + '#' * ( cpu_idle / SCALE ) )

      # Job status
      job_all = Cluster[ each ].job.size
      job_done = Cluster[ each ].job_done.size
      job_inprogress = Cluster[ each ].job_inprogress.size
      job_left = job_all - job_done - job_inprogress
      puts sprintf( "Job #{ job_status( job_done, job_inprogress, job_left ) }: %s", Log.slate( '#' ) * ( job_done / SCALE ) + Log.green( '#' ) * ( job_inprogress / SCALE ) + '#' * ( job_left / SCALE ) )

      puts
    end
  end


  def self.cpu_status inuse, idle
    sprintf "(%3d inuse/%3d idle)", inuse, idle
  end


  def self.job_status done, inprogress, left
    sprintf "(%3d done/%3d inprogress/%3d left)", done, inprogress, left
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
