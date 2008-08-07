#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'clusters'
require 'dach_api'
require 'jobs'
require 'shell'
require 'socket'
require 'tempfile'


class Novad
  def initialize
    @dach_api = DachAPI.new
    @log = Tempfile.new( 'novad' )
  end


  # [TODO] ジョブのディスパッチコマンド (dispatch)
  # [TODO] ジョブの実行時間推定コマンド (guess)
  # [???] ほかに必要なコマンドは？？
  def start
    socket = TCPServer.open( 3225 )
    loop do
      Thread.start( socket.accept ) do | s |
        command = s.gets.chomp
        case command
        when /init/
          init s
        when /get_problem (.*)/
          get_problem s, $1
        else
          log "ERROR: unknown command #{ command }"
        end
        s.close
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def init socket
    log 'init'

    cleanup_files
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


  def log str
    @log.puts "#{ Time.now }: #{ str }"
    @log.flush
  end


  def ok socket
    log 'OK'
    socket.puts "OK"
  end


  def command cmd
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        log '  ' + line
      end
      shell.on_stderr do | line |
        log '  ' + line
      end
      shell.on_failure do
        raise %{Command "#{ cmd }" failed.}
      end
      
      log "CMD: '#{ cmd }'"
      shell.exec cmd
    end
  end


  def gxpc_init
    command "gxpc quit"
    command "gxpc use ssh #{ cluster_name }"
    first = Clusters.list( cluster_name.to_sym )[ :list ].first.tr( cluster_name, '' )
    last = Clusters.list( cluster_name.to_sym )[ :list ].last.tr( cluster_name, '' )
    command "gxpc explore #{ cluster_name }[[#{ first }-#{ last }]]"
  end


  def gxpc_quit
    command "gxpc quit"
  end


  # [???] ほかに pkill すべきプロセスは？？
  def gxpc_killall
    command "gxpc e pkill detect3"
    command "gxpc e pkill match2"
    command "gxpc e pkill imsub3vp3"
  end


  def gxpc_dachmon
    command 'gxpc e /home/dach000/nova/dachmon.rb'
  end


  def cleanup_files
    results.each do | each |
      log "rm #{ each }"
      FileUtils.rm each
    end
  end


  def cluster_name
    /\A([a-zA-Z]+)\d+/=~ `hostname`
    $1
  end


  def results
    Dir.glob File.join( @dach_api.result_dir, '*.result' )
  end
end


novad = Novad.new
novad.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
