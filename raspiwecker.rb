#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'


require 'robustserver'
require 'daemons'
require 'eventmachine'
require 'ruby-mpd'


class AlarmClockServer < RobustServer
	
  def initialize
		super
			watch pin: 18 do |pin|
				if pin.value == 1
					puts "mpc einschalten"
				else
					puts "mpc ausschalten"
				end
			end
    end
		
	def run
end

AlarmClockServer.new.main
