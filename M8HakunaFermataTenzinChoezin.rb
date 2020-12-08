#set the tempo for the entire song and its pieces
tempo = 70
use_bpm tempo

#starts the track with a nostalgic sound
in_thread(name: :vinyl_start) do
  sample :vinyl_rewind, lpf: 95, amp: 0.65
end

#provides background vinyl record noise that gives a lofi effect
in_thread(name: :vinyl_background) do
  
  live_loop :vinyl_hiss do
    #when this becomes true, we hear the hiss, stop if not
    if get[:vinyl_on]
      sample :vinyl_hiss, lpf: 95, amp: 0.65
      sleep 1
    else
      stop
    end
  end
end

#phone sound effect for nostalgic effect
in_thread(name: :phone_ambience) do
  
  sleep 22
  loop do
    #this runs as long as the vinyl hiss is running
    if get[:vinyl_on]
      sample :mehackit_phone2
      sleep 24
    else
      sleep 1
    end
  end
end

#the initial simple beat before the more intricate beat
in_thread(name: :pre_beat) do
  
  sleep 23
  #run the following until :beat_drop is true
  until get[:beat_drop]
    
    sample :elec_hi_snare, lpf: 100
    sleep 2
    
  end
end

#provides the intricate beat, as well as sending information to trigger other threads
in_thread(name: :beat) do
  
  #sets the initial value for other threads
  set :start_middle, false
  set :start_ending, false
  
  #tracks the amount of times going through one round of chord progressiion
  counter = 0
  
  live_loop :post_drop_beat do
    #sync up the timing to the :keys live_loop
    sync :keys
    
    #once :beat_drop becomes true
    if get[:beat_drop]
      counter += 1
      
      #once above threshold, begin ending melody
      if counter >= 14
        set :start_ending, true
      end
      
      #once above threshold, end the middle riff
      if counter >= 15
        set :start_middle, false
        
        #run the middle riff
      else
        set :start_middle, true
      end
      
      #crux of the more intricate beat
      2.times do
        sample :drum_heavy_kick, lpf: 115
        sleep 0.75
        sample :drum_heavy_kick, lpf: 115
        sleep 0.25
        sample :drum_snare_hard, lpf: 105
        sleep 0.5
        sample :drum_heavy_kick, lpf: 115
        sleep 1
        sample :drum_cymbal_closed, lpf: 115
        sleep 0.25
        sample :drum_cymbal_closed, lpf: 115
        sleep 0.25
        sample :drum_snare_hard, lpf: 105
        sleep 1
      end
      
      #when :beat_drop is false
    else
      sleep 1
    end
  end
end

#provides the main harmony throughout the song, the core chord progression in E minor
in_thread(name: :harmony) do
  
  sleep 6
  
  #specify synth type
  use_synth :tri
  
  #list of chords utilized in the progression
  chords = [(chord :E, :minor7), (chord :C, :major7), (chord :G, :major7), (chord :D, :dom7)]
  
  
  live_loop :keys do
    #start the harmony if true, when not true, stop
    if get[:harmony_start]
      #loop through the chords, sleeping 2 beats at a time with specified param
      play_pattern_timed chords, 2, release: 2, cutoff: 80, amp: 0.75
    else
      stop
    end
  end
end


#initial melody
in_thread(name: :beginning_melody) do
  
  set :beat_drop, false
  
  use_synth :pluck
  
  #create ring structure of notes for ease of looping through
  notes = [:B4, :C5, :D5, :E4, :G4, :A4, :Fs4].ring
  sleep 54
  8.times do
    sleep 1
    #play notes looping through list of rest beats
    play_pattern_timed notes, [0.5, 0.5, 2.5, 0.5, 0.5, 1, 1.5], amp: 2
  end
  play :E4
  sleep 16
  set :beat_drop, true
end

#creates the improv riff in the middle of the song
in_thread(name: :middle_riff) do
  
  use_synth :pluck
  
  #declare a scale in E minor key
  e_min_scale = scale(:E, :minor)
  
  
  loop do
    #once the middle can begin
    if get[:start_middle]
      
      #randomly choose a value for r from given list
      r = [0.25, 0.25, 0.5, 1].choose
      
      #randomly play a note from the E minor scale, using chosen r value as release and sleep value
      play e_min_scale.choose, release: r, amp: 2
      sleep r
    else
      sleep 1
    end
  end
end

#provides the bass for the track
in_thread(name: :bass) do
  
  use_synth :tri
  
  #create a ring of notes that compose the bass line
  bass_notes = [:E2, :E2, :E2, :E2, :G2, :G2, :G2, :D2].ring
  
  loop do
    
    #when :beat_drop is true
    if get[:beat_drop]
      #play through the bass notes with the given rest beats
      play_pattern_timed bass_notes, [0.5, 1, 0.5, 2, 0.5, 1, 0.5, 2], amp: 0.25
    else
      sleep 1
    end
  end
end

#the ending melody for the track
in_thread(name: :end_melody) do
  
  use_synth :pluck
  
  #create a ring structure with the given notes
  notes = [:B4, :C5, :D5, :E4, :G4, :A4, :Fs4].ring
  
  set :harmony_start, true
  set :vinyl_on, true
  
  #makes sure we don't proceed through the rest of the code, until the ending can begin
  while not get[:start_ending]
    sleep 1
  end
  
  #sync up with the harmony
  sync :keys
  
  8.times do
    sleep 1
    #play notes with the given rest beats
    play_pattern_timed notes, [0.5, 0.5, 2.5, 0.5, 0.5, 1, 1.5], amp: 2
  end
  
  #turn beat off
  set :beat_drop, false
  
  2.times do
    sleep 1
    #play notes with the given rest beats
    play_pattern_timed notes, [0.5, 0.5, 2.5, 0.5, 0.5, 1, 1.5], amp: 2
  end
  
  play :E4
  
  #turn harmony off
  set :harmony_start, false
  
  #end notes ring structure
  end_notes = [:C5, :B4, :D5, :C5, :B4, :E4, :G4, :A4, :Fs4, :E4].ring
  sleep 1
  
  2.times do
    #play end notes with the given rest beats
    play_pattern_timed end_notes, [0.5, 0.5, 0.5, 0.5, 2, 0.5, 0.5, 1, 1, 1], amp: 1.5
  end
  
  sleep 4
  
  #final riff notes ring structure
  final_riff = [:E4, :G4, :A4, :Fs4, :E4].ring
  
  #play final riff notes with the given rest beats
  play_pattern_timed final_riff, [0.5, 0.5, 1, 2, 1], amp: 1.5
  sleep 4
  
  #turn vinyl hiss off
  set :vinyl_on, false
  
end