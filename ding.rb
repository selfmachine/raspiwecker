#!/usr/bin/env ruby
require 'bundler/setup'

require 'pi_piper'
include PiPiper

watch pin: 14 do |pin|
	p pin
  puts "Pin 14 changed from #{pin.last_value} to #{pin.value}"
end

watch pin: 15 do |pin|
	p pin
  puts "Pin 15 changed from #{pin.last_value} to #{pin.value}"
end

watch pin: 18 do |pin|
	p pin
  puts "Pin 18 changed from #{pin.last_value} to #{pin.value}"
end

PiPiper.wait