#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'clusters'
require 'dach_api'
require 'dacha'
require 'daemonize'
require 'job'
require 'jobs'
require 'shell'
require 'socket'
require 'tempfile'


class Novad
  def initialize
    @dach_api = DachAPI.new
    @dacha = Dacha.new( cluster_name.to_sym )
    @log = Tempfile.new( 'novad' )
  end


  # [TODO] ジョブの実行時間推定コマンド (guess)
  # [???] ほかには？
  def start
    log 'novad started.'
    open_socket

    loop do
      Thread.start( @socket.accept ) do | s |
        begin
          command = s.gets.chomp
          case command
          when /get_problem (.*)/
            get_problem s, $1
          when /get_nodes/
            get_nodes s
          when /dispatch (.*) (.*)/
            dispatch s, $1, $2
          when /quit/
            @log.close true
            exit 0
          else
            log "ERROR: unknown command #{ command }"
          end
          s.close
        rescue
          log $!.to_s
          $!.backtrace.each do | each |
            log each
          end
        end
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def open_socket
    begin
      @socket = TCPServer.open( 3225 ) 
    rescue
      log $!.to_s
      $!.backtrace.each do | each |
        log each
      end
    end
  end


  def init socket
    log 'init'

    gxpc_init
    gxpc_killall
    gxpc_dachmon
    gxpc_quit

    ok socket
  end


  # [TODO] init せずに get_problem したら怒るべし
  def get_problem socket, id
    @dach_api.get_problem id

    log "get_problem #{ id }"
    log "TRIAL ID = #{ @dach_api.trial_id }"
    log "FITS DIR = #{ @dach_api.fits_dir }"

    socket.puts Jobs.list( @dach_api.fits_dir ).join( ' ' )

    ok socket
  end


  def get_nodes socket
    log "get_nodes #{ cluster_name }"

    cpus = @dacha.list.sort_by do | each |
      each.load_avg
    end
    nodes = cpus.collect do | each |
      each.name
    end.uniq

    socket.puts nodes.join( ' ' )

    ok socket
  end


  def dispatch socket, host, fits
    log "dispatch #{ host } #{ fits }"

    job = Job.new( fits, @dach_api.fits_dir )
    cmd = "ssh #{ host } #{ job.to_cmd }"

    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        socket.puts line
      end
      shell.on_stderr do | line |
        log "WARN [#{ fits }]: #{ line }"
      end
      shell.on_success do
        ok socket
      end
      shell.on_failure do
        error socket, %{Command "#{ cmd }" failed.}
      end

      log "CMD: '#{ cmd }'"
      shell.exec cmd
    end
  end


  def log str
    @log.puts "#{ Time.now }: #{ str }"
    @log.flush
  end


  def ok socket
    log 'OK'
    socket.puts 'OK'
  end


  def error socket, msg
    log "ERROR: #{ msg }"
    socket.puts "ERROR: #{ msg }"
  end


  def command cmd
    log "CMD: '#{ cmd }'"
    system cmd
#     Popen3::Shell.open do | shell |
#       shell.on_stdout do | line |
#         log '  ' + line
#       end
#       shell.on_stderr do | line |
#         log '  ' + line
#       end
#       shell.on_failure do
#         raise %{Command "#{ cmd }" failed.}
#       end
      
#       log "CMD: '#{ cmd }'"
#       shell.exec cmd
#     end
  end


  def gxpc_quit
    command "gxpc quit"
  end


  # [???] ほかに pkill すべきプロセスは？？
  # [???] pkill する順番は？
  def gxpc_killall
    command "gxpc e pkill detect3"
    command "gxpc e pkill match2"
    command "gxpc e pkill mask3"
    command "gxpc e pkill sex"
    command "gxpc e pkill imsub3vp3"
  end


  def gxpc_dachmon
    command 'gxpc e /home/dach000/nova/dachmon.rb'
  end


  def cluster_name
    /\A([a-zA-Z]+)\d+/=~ `hostname`
    $1
  end
end


include Daemonize
daemonize
Novad.new.start

sleep 10


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
