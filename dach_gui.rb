#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


$LOAD_PATH.unshift File.dirname( __FILE__ )


require 'run'
require 'tk'


class DachGUI
  def initialize clusters
    @run = Run.new( clusters )
    Tk.root.title( 'Dach GUI' )
  end


  def start
    begin
      @run.cleanup_results
      @run.start_novad
      @run.cleanup_processes
      @run.get_problem
      @run.get_nodes
      mainloop
    rescue
      $stderr.puts $!.to_str
      $!.backtrace.each do | each |
        $stderr.puts each
      end
      @run.cleanup
    end
  end


  ################################################################################
  private
  ################################################################################


  def mainloop
    @run.clusters.each do | c |
      TkLabel.new( nil, 'text' => c.to_s ).pack
      create_problem_label c
      create_node_label c
    end
    TkButton.new( nil, 
                  'command' => proc {
                    @run.dispatch_first
                  },
                  'text' => 'Start' ).pack
    Tk.mainloop
  end


  def create_problem_label cluster
    f = TkFrame.new {
      pack 'fill' => 'x'
    }
    @run.problem[ cluster ].each_with_index do | each, index |
      TkLabel.new( f ) {
        text each
        font 'size' => 8
        grid( 'row' => index / 40, 
              'column' => index % 40,
              'sticky' => 'news' )
      }
    end
  end


  def create_node_label cluster
    f = TkFrame.new {
      pack 'fill' => 'x'
    }
    @run.node[ cluster ].each_with_index do | each, index |
      TkLabel.new( f ) {
        text each.tr( cluster.to_s, '' )
        font 'size' => 8
        grid( 'row' => index / 40, 
              'column' => index % 40,
              'sticky' => 'news' )
      }
    end
  end
end


dach_gui = DachGUI.new( ARGV )
dach_gui.start


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
