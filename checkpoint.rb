require 'fileutils'
require 'log'


class Checkpoint
  DIR = File.join( File.dirname( __FILE__ ), 'checkpoint' )


  def self.save args
    unless FileTest.exists?( DIR )
      FileUtils.mkdir DIR
    end

    if args[ :trial_id ]
      File.open( File.join( DIR, 'trial_id' ), 'w' ) do | f |
        f.puts args[ :trial_id ]
        $stderr.puts "#{ Log.green( 'CHECKPOINT' ) } trial_id = #{ args[ :trial_id ] }"
      end
    end
  end


  def self.load value
    if value == :trial_id
      File.read( File.join( DIR, 'trial_id' ) ).chomp
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
