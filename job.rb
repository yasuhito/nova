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


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
