require 'thread'


class Log
  PINK = "[0;31m"
  GREEN = "[0;32m"
  YELLOW = "[0;33m"
  SLATE = "[0;34m"
  ORANGE = "[0;35m"
  BLUE = "[0;36m"
  RESET = "[0m"


  @@log = File.open( '/tmp/dach000.log', 'w' )
  @@log.sync = true

  @@log_mutex = Mutex.new


  def self.pink str
    PINK + str + RESET
  end


  def self.orange str
    ORANGE + str + RESET
  end


  def self.slate str
    SLATE + str + RESET
  end


  def self.green str
    GREEN + str + RESET
  end


  def self.yellow str
    YELLOW + str + RESET
  end

 
  def self.warn str
    @@log_mutex.synchronize do
      @@log.puts "#{ Time.now }: #{ yellow( str ) }"
    end
  end


  def self.info str
    @@log_mutex.synchronize do
      @@log.puts "#{ Time.now }: #{ str }"
    end
  end


  def self.error str
    @@log_mutex.synchronize do
      @@log.puts "#{ Time.now }: #{ pink( str ) }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
