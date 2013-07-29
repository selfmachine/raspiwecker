#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'ruby-mpd'

mpd = MPD.new 'localhost', 6600
mpd.connect

if mpd.repeat? == false
	mpd.repeat=true
end

ARGF.each do |eingabe|
	eingabe.chomp!
  if eingabe == "1"
		puts "mpd eingeschaltet"
		mpd.play
		song = mpd.current_song
		puts "Current Song: #{song.artist} - #{song.title}"
	elsif eingabe == "next"
		mpd.next
		song = mpd.current_song
		puts "Current Song: #{song.artist} - #{song.title}"
	elsif eingabe == "prev"
		mpd.previous
		song = mpd.current_song
		puts "Current Song: #{song.artist} - #{song.title}"
	elsif eingabe == "0"
		puts "mpd ausgeschaltet"
		mpd.stop
	end
end
