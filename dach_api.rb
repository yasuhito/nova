require 'fileutils'


class DachAPI
  attr_reader :fits_dir
  attr_reader :problem_id
  attr_reader :trial_id


  def get_problem problem_id
    @problem_id = problem_id

    cmd = "#{ dach_api } --get_problem #{ @problem_id }"
    output = `#{ cmd }`.chomp
    unless /\A(\S+) (\S+)\Z/=~ output
      raise "Parse Error! #{ output }"
    end

    @trial_id = $1
    # @fits_dir = File.join( '/tmp/dach000', $2 )
    @fits_dir = File.join( '/home/dach911', $2 )
  end


  def check_ans result
    # Check the answer
    cmd = "#{ dach_api } --check_ans #{ @trial_id } #{ result }"
    $stderr.puts cmd if $DEBUG
    system cmd
  end


  ################################################################################
  private
  ################################################################################


  def dach_api
    '/home/dach911/dach_api/dach_api'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
