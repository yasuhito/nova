#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'run'
require 'thread'
require 'tk'


class Threads
  def initialize
    @threads = []
    @mutex = Mutex.new
    @cv = ConditionVariable.new
  end


  def dispatch cluster
    Thread.new do
      begin
        @threads << Thread.current
        yield cluster
      rescue
        $stderr.puts $!.to_str
        $!.backtrace.each do | each |
          $stderr.puts each
        end
      ensure
        @mutex.synchronize do
          @threads.delete Thread.current
          @cv.signal
        end
      end
    end
  end


  def shutdown
    @mutex.synchronize do
      until @threads.empty?
        @cv.wait @mutex
      end
    end
  end
end


class TextFrame < TkText
  include TkComposite


  def initialize_composite keys = {}
    keys = keys.dup

    @v_scroll = TkScrollbar.new( @frame, 'orient' => 'vertical' )
    @text = TkText.new( @frame )

    @path = @text.path

    @text.yscrollcommand proc { | first, last |
      @v_scroll.set first, last
    }
    @v_scroll.command proc { | *args |
      @text.yview *args
    }
    @v_scroll.grid 'row'=>0, 'column'=>1, 'sticky'=>'ns'

    TkGrid.rowconfigure @frame, 0, 'weight'=>1, 'minsize'=>0
    TkGrid.columnconfigure @frame, 0, 'weight'=>1, 'minsize'=>0
    @text.grid 'row'=>0, 'column'=>0, 'sticky'=>'news'

    color = keys.delete( 'textbackground' )
    textbackground( color ) if color

    configure keys unless keys.empty?
  end


  def textbackground color
    @text.background color
  end
end


class DachGUI
  def initialize problem, *clusters
    @run = Run.new( problem, clusters )

    @root = TkRoot.new
    @root.title( 'Dach GUI' )

    @status = {}
    @f_text = {}
    setup_window
  end


  ################################################################################
  private
  ################################################################################


  def update cluster
    jobs = 'Jobs: ' +  @run.job_all[ cluster ].join( ' ' )

    nodes = 'Nodes: ' + @run.node[ cluster ].collect do | each |
      each.tr cluster, ''
    end.sort.join( ' ' )

    disp_text cluster, jobs + "\n" + nodes
  end


  def run
    do_parallel( @run.clusters ) do | each |
      until @run.finished?( each )
        sleep 0.1 # sleep a little to avoid segfault (Tcl/Tk problem)
        @run.continue each
        update each
      end
    end
  end


  def start
    puts "started"

    begin
      cleanup_results
      start_novad
      cleanup_processes
      get_job
      get_nodes
      run
    rescue
      $stderr.puts $!.to_str
      $!.backtrace.each do | each |
        $stderr.puts each
      end
    ensure
      cleanup
    end

    puts 'OK'
  end


  def get_nodes
    do_parallel( @run.clusters ) do | each |
      show_status each, 'Getting node list...'
      @run.get_nodes each
      show_status each, ''
    end
  end


  def get_job
    do_parallel( @run.clusters ) do | each |
      show_status each, 'Getting job list...'
      @run.get_job each
      show_status each, ''
    end
  end


  def cleanup
    do_parallel( @run.novad ) do | each |
      @run.cleanup *each
    end     
  end


  def cleanup_results
    do_parallel( @run.clusters ) do | each |
      show_status each, 'Cleaning up old *.result files...'
      @run.cleanup_results each
      show_status each, ''
    end
  end


  def show_status cluster, str
    @status[ cluster ].text = str
  end


  def cleanup_processes
    do_parallel( @run.clusters ) do | each |
      show_status each, 'Cleaning up old dach processes...'
      @run.cleanup_processes each
      show_status each, ''
    end
  end


  def start_novad
    do_parallel( @run.clusters ) do | each |
      show_status each, 'Starting novad...'
      @run.start_novad each
      show_status each, ''
    end
  end


  def do_parallel list, &block
    threads = Threads.new
    list.each do | each |
      threads.dispatch each, &block
    end
    threads.shutdown
  end


  def setup_window
    @run.clusters.each do | c |
      status = @status

      TkFrame.new( @root ) do | f |
        # クラスタ名
        TkLabel.new( f ) {
          text c.to_s
          pack 'side' => 'left'
        }
        # クラスタの状態 (要約)
        status[ c ] = TkLabel.new( f ) {
          text ''
          pack 'side' => 'left'
        }
        pack 'fill' => 'x'
      end

      @f_text[ c ] = TextFrame.new( @root, 'height' => 10, 'width' => 65 ) {
        bindtags bindtags - [ TkText ]
        configure 'takefocus', 0
      }.pack( 'expand' => true, 'fill' => 'x' )
    end

    TkButton.new( @root,
                  'text' => 'Start',
                  'command' => proc { start } ).pack( 'side' => 'left' )
    TkButton.new( @root,
                  'text' => 'Quit',
                  'command' => proc { cleanup; exit 0 } ).pack( 'side' => 'left' )
  end


  def disp_text cluster, text
    @f_text[ cluster ].value = text
    colorize cluster
  end


  def colorize cluster
    tag_error = TkTextTag.new( @f_text[ cluster ], 'foreground' => 'red' )
    tag_done = TkTextTag.new( @f_text[ cluster ], 'foreground' => 'blue' )
    tag_progress = TkTextTag.new( @f_text[ cluster ], 'foreground' => 'green' )

    idx = '0.0'
    @run.job_inprogress[ cluster ].each do | each |
      p each
      if ( idx = @f_text[ cluster ].search( /#{ each }/, "#{ idx } + 1 char", 'end' ) ) != ''
        @f_text[ cluster ].tag_add( tag_progress, idx, "#{ idx } + 1 char" )
      end
    end

#     # 対象日の行への色付け
#     # 文字列を検索して、テキストタグを割り当てています
#     idx = @f_text.search(%r|^#{@f_param.get_target_day.tr('/','.')}|, '1.0')
#     @f_text.tag_add(tag_TargetDay, idx, "#{idx} lineend") if idx

#     # グラフ表示文字への色付け
#     # 文字を検索して、テキストタグを割り当てています
#     idx = '6.0'
#     while (idx = @f_text.search(/P/, "#{idx} + 1 char", 'end')) != ''
#       @f_text.tag_add(tag_P, idx, "#{idx} + 1 char")
#     end
#     idx = '6.0'
#     while (idx = @f_text.search(/E/, "#{idx} + 1 char", 'end')) != ''
#       @f_text.tag_add(tag_E, idx, "#{idx} + 1 char")
#     end
#     idx = '6.0'
#     while (idx = @f_text.search(/M/, "#{idx} + 1 char", 'end')) != ''
#       @f_text.tag_add(tag_M, idx, "#{idx} + 1 char")
#     end
  end
end


dach_gui = DachGUI.new( *ARGV )
Tk.mainloop_watchdog


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
