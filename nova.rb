!/usr/bin/env ruby


$PROBLEM_ID = 'sample0'
$DACH_API = '/home/dach911/dach_api/dach_api'


def get_problem
  get_problem_out = `#{ $DACH_API } --get_problem #{ $PROBLEM_ID }`.chomp
  raise "Parse Error! dach_api --get_problem" unless /\A(\S+) (\S+)\Z/=~ get_problem_out
  $TRIAL_ID = $1
  $FITS_DIR = File.join( '/home/dach911', $2 )
end


def fits_files
  Dir.glob File.join( $FITS_DIR, "*.fits" )
end


def fits
  fits = {}
  fits_files.each do | each |
    fname = File.basename( each )
    raise "Parse Error! *.fits file name" unless /\Ar(\d\d\d_\d\d)_t[01]\.fits\Z/=~ fname
    fits[ $1 ] ? fits[ $1 ] << each : fits[ $1 ] = [ each ] 
  end
  fits
end


def superfind
  fits.each_pair do | key, value |
    result = "/home/dach000/result/#{ key }.result"
    cmd = "/home/dach/finder/dach.sh #{ value.sort[ 0 ] } #{ value.sort[ 1 ] } > #{ result }"
    puts cmd
    system "time " + cmd
  end
end


def check_ans
  Dir.glob( "/home/dach000/result/*.result" ).each do | each |
    get_problem # BUG??
    cmd = "#{ $DACH_API } --check_ans #{ $TRIAL_ID } #{ each }"
    system cmd
    puts cmd
  end
end


get_problem
superfind
check_ans


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
