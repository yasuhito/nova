require 'job'


class Jobs
  def self.list fits_dir
    fits_files( fits_dir ).collect do | each |
      if /\Ar(\d+_\d+)_t0\.fits\Z/=~ File.basename( each )
        Job.new $1, fits_dir
      end
    end.compact
  end


  def self.fits_files fits_dir
    Dir.glob File.join( fits_dir, "*.fits" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
