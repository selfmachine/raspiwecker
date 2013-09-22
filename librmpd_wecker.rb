#!/usr/bin/env ruby
require 'bundler/setup'

require 'eventmachine'

require 'rubygems'
require 'librmpd'


# Musikwiedergabe starten
def play
	puts "mpd eingeschaltet"
	@mpd.play
	sleep 1
	print_song
end


# Weckzeit einstellen
def set_timer
	# jetzige Zeit einstellen:
	now = Time.new
	puts now

	# Weckzeit einstellen:
	print "stunde: "
	h = gets
	print "minute: "
	m = gets

	create_repeating_timer(h, m)
end


# Thread erstellen, der auf Weckzeitpunkt wartet, 
# es gibt zu jedem Zeitpunkt hoechstens einen (zusaetzlichen) geben,
# bei Korrektur der Weckzeit oder De- und Reaktivierung wird dieser einfach ersetzt.
# Dafür wird er immerzu in @thr gespeichert.
def create_repeating_timer(h, m)
	if @thr.alive?
	  Thread.kill(@thr);
	  puts "Weckzeit ueberschrieben"
	end
	
	@thr = Thread.new {
	    while true
	      secs_to_sleep = calc_secs(h, m)
	      sleep secs_to_sleep
	      puts "aufgewacht!"
	      play
	      sleep 1 # damit es nicht zu 0-Sekunden-Wartezeiten kommt
	    end
	}
end


# Berechnet fuer eine uebergebene Weckzeit (Stunde, Minute) die Wartezeit bis zum naechsten
# Auftreten und liefert gleich entsprechende Ausgaben
def calc_secs(h, m)
	now = Time.new
	@alarm_time = Time.new(now.year, now.month, now.day, h, m)
	
	# Wenn Weckzeit vor Jetztzeit oder zugleich, soll sie auf naechsten Tag gesetzt werden
	if @alarm_time - now <= 0
		@alarm_time = @alarm_time + 24*60*60
	end
	
	puts "naechste weckzeit: "
	puts @alarm_time

	# Differenz berechnen und solange schlafen:
	secs_to_sleep = (@alarm_time - now).to_i
	h_left = secs_to_sleep / (60*60)
	m_left = (secs_to_sleep - h_left*60*60) / 60
	s_left = secs_to_sleep - h_left*60*60 - m_left*60
	puts "#{secs_to_sleep} seconds left to sleep / #{h_left}:#{m_left}:#{s_left}"
	return secs_to_sleep
end


# Sorgt fuer eine Ausgabe der derzeit eingestellten Weckzeit, sowie ob diese aktiv ist
# oder deaktiviert (mittels an/aus einzustellen)
def print_alarm
	puts @alarm_time
	if @thr.alive?
	  puts "aktiviert"
	else 
	  puts "deaktiviert"
	end
end


def snooze
	if @mpd.playing?
		@mpd.stop
		EM.run do
			EM.add_timer(10) do
				@mpd.play
				EM.stop_event_loop
			end
		end
	end
end


def print_song
	song = @mpd.current_song
	puts "Current Song: #{song.artist} - #{song.title}"
end


def update_print_song(new_song)
	puts "New current Song: #{new_song.artist} - #{new_song.title}"
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


def volumetest
	vol = @mpd.volume
	puts "volume is #{vol}"
end


def activate
       create_repeating_timer(@alarm_time.hour, @alarm_time.min)
end


def deactivate
	Thread.kill(@thr);
end


@mpd = MPD.new 'localhost', 6600
@mpd.register_callback(method('update_print_song'), MPD::CURRENT_SONG_CALLBACK)
@mpd.connect(true)

@alarm_time = nil;


# Loopen der Playlist aktivieren, falls noch nicht aktiviert:
if @mpd.repeat? == false
	@mpd.repeat=true
end


# kurz einen neuen Thread thr erzeugen, damit nachher abgefragt werden
# kann, ob er alive ist
@thr = Thread.new {}



ARGF.each do |eingabe|
	eingabe.chomp!
	if eingabe == "play"
		play
	elsif eingabe == "stop"
		puts "mpd ausgeschaltet"
		@mpd.stop
	elsif eingabe == "snooze"
		snooze
	elsif eingabe == "weckzeit"
		set_timer
	elsif eingabe == "next"
		switch_to_next_channel
	elsif eingabe == "prev"
		switch_to_previous_channel
	elsif eingabe == "+"
		volume_up
	elsif eingabe == "-"
		volume_down
	elsif eingabe == "volumetest"
		volumetest
	elsif eingabe == "wann"
		print_alarm
	elsif eingabe == "an"
		activate
	elsif eingabe == "aus"
		deactivate
	end
end