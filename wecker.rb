#!/usr/bin/env ruby
require 'bundler/setup'

require 'ruby-mpd'

class MPD::Song
	attr_reader :data
end

@mpd = MPD.new 'localhost', 6600
@mpd.connect

# Loopen der Playlist aktivieren, falls noch nicht aktiviert:
if @mpd.repeat? == false
	@mpd.repeat=true
end


def play
	puts "mpd eingeschaltet"
	@mpd.play
	print_song
end

def stop
	puts "mpd ausgeschaltet"
	@mpd.stop
end

def weckzeit_stellen
	# jetzige Zeit einstellen:
	now = Time.new
	puts now

	# Weckzeit einstellen:
	print "stunde: "
	h = gets
	print "minute: "
	m = gets

	alarm_time = Time.new(now.year, now.month, now.day, h, m)
	puts alarm_time

	if alarm_time - now < 0
		alarm_time = alarm_time + 24*60*60
	end

	# Differenz berechnen und solange schlafen:
	secs_to_sleep = (alarm_time - now).to_i
	puts "#{secs_to_sleep} seconds left to sleep"
	h_left = secs_to_sleep / (60*60)
	m_left = (secs_to_sleep - h_left*60*60) / 60
	s_left = secs_to_sleep - h_left*60*60 - m_left*60
	puts "#{h_left}:#{m_left}:#{s_left} left to sleep"
	
	
	sleep secs_to_sleep
	puts "aufgewacht!"
	play
end

def snooze
	if @mpd.playing?
		@mpd.stop
		sleep 10
		@mpd.play
	end
end

def print_song
		song = @mpd.current_song
		sender = song.data[:name]
		puts "#{sender}#{song.artist} - #{song.title}"

end

def switch_to_next_channel
		@mpd.next
		print_song
end

def switch_to_previous_channel
		@mpd.previous
		print_song
end

def volume_up
	vol = @mpd.volume
	if vol < 100
		vol = vol + 5
	end
	@mpd.volume=vol
	puts "set volume to #{vol}"
end

def volume_down
	vol = @mpd.volume
	if vol > 0
		vol = vol - 5
	end
	@mpd.volume=vol
	puts "set volume to #{vol}"
end

ARGF.each do |eingabe|
	eingabe.chomp!
	if eingabe == "play"
		play
	elsif eingabe == "stop"
		stop
	elsif eingabe == "snooze"
		snooze
	elsif eingabe == "weckzeit"
		weckzeit_stellen	
	elsif eingabe == "next"
		switch_to_next_channel
	elsif eingabe == "prev"
		switch_to_previous_channel
	elsif eingabe == "+"
		volume_up
	elsif eingabe == "-"
		volume_down
	end
end