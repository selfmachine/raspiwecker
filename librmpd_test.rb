#!/usr/bin/env ruby

require 'rubygems'
require 'librmpd'
    
mpd = MPD.new 'localhost', 6600

mpd.connect

if mpd.stopped?
  mpd.play
end
song = mpd.current_song
puts "Current Song: #{song.artist} - #{song.title}"

mpd.stop