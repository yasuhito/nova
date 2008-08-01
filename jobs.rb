class Jobs
  class Job
    attr_reader :name


    def initialize name, fits_dir
      @name = name
      @fits_dir = fits_dir
    end


    def to_cmd
      "/home/dach/finder/dach.sh #{ fits_pair.join( ' ' ) }"
    end


    def to_s
      @name
    end


    ################################################################################
    private
    ################################################################################


    def fits_pair
      [ File.join( @fits_dir, "r#{ @name }_t#{ 0 }.fits" ),
        File.join( @fits_dir, "r#{ @name }_t#{ 1 }.fits" ) ]
    end
  end


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
