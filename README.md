# ML-2

Second generation of Akai Fire based "groovebox", now using Sunvox as the audio "backend".


## Preview Demo Video

[![Video previewing current ML-2 status](https://img.youtube.com/vi/JpadEkXXo2E/0.jpg)](https://www.youtube.com/watch?v=JpadEkXXo2E)

## Todo

R1: Modules & Playing
* [X] volume dial, master volume, show on Oled
* [X] send note off on pad "keyboard" key release
* [X] use widgets for pads/oled, eg. chromatic-keyboard, module list, etc
* [X] show list of modules in Note mode, filtered to only include "playable" types (generator, drumsynth, multisynth etc) and not inc compressor, output etc
* [X] control with dials selected module "controls", display value on Oled, use pattern button to cycle thru pages of 3 "controls"
* [X] convert modes to be widgets
* [X] show names of controls when switching controller "pages"
* [X] heading + large number widget for Oled
* [X] chromatic keyboard on pads for Note mode
* [X] show connected output module pads while module pad (+shift) pressed
* [X] add/remove modules using Oled+select dial to choose new module to add
* [X] connect/disconnect modules together using pads
* [X] better module controllers change with encoders
* [ ] convert transport controls class to be a widget
* [ ] scales keyboard (C maj, dorian, etc)


R2: Project Management
* [ ] Go into project menu on Oled with Shift+Browser button
* [ ] Create new project (using project menu item), named "Project 1"," Project 2"," Project 3" etc
* [ ] Load project from list
* [ ] Set project BPM (using metronome button + select dial)

R3: Step Sequencing
* [ ] Add, remove default note steps for current module
* [ ] Modify note, velocity of steps
* [ ] Scroll through tracks list on step view with select dial
* [ ] Quick way of switching current module (shfit+select dial??)
* [ ] Page through step pages with using grid left-right buttons
* [ ] Auto add step page when adding step to non existent page after doing "next page" button
* [ ] Show play head during playback
* [ ] Auto add track when adding step to track with no steps yet defined
* [ ] Set default module (instrument) for a track
* [ ] Mute/Solo tracks (using buttons)
* [ ] Modify multiple steps (eg change velocity) by holding down multiple pads
* [ ] Add fx commands to steps
* [ ] Add new Sunvox Pattern (set of tracks) with Pattern down button (if next pattern does not yet exist)

R4: Visualisation & mixing
* [ ] Control panning
* [ ] Mixer mode: ?
* [ ] Oled show Main Output level (bars) 
* [ ] Oled show output level of any module
* [ ] Oled show waveform of any modules output

R5: Misc Improvements
* [ ] Rename current project (use pads as qwerty keybd)
* [ ] editing of complex module controls: eg. envelopes 

R6: Advanced Arrangement
* [ ] Arrange Patterns on Timeline (using arranger mode? alt mode of perform mode? aka "overview")
* [ ] Live record into a track (or multiple tracks if chords?)


## Command reference

### All Modes
 
VOLUME:      global volume


### Step Mode (STEP button)

TODO

### Module Mode (DRUM button)

BROWSER:     toggle browsing mode to select module type to add (press SELECT to add)
ALT+SELECT:  delete the currently selected module!
SHIFT+Pad:   show the modules outputs
GRID:        up/down 1 octave for pad chromatic keyboard

PAN/FILTER/RESONANCE Encoders: Current module controllers in pages, page through with PATTERN buttons 

#### Inter-Module connections
While holding down a Pad, tap another pad to connect from first to second pad. Or disconnect first from second pad
if they were previously connected.

### Note Mode (NOTE button)

GRID:        up/down 1 octave for pad chromatic keyboard

### Performance Mode (PERFORM button)

TODO


# References 

On using Riverpod with pure Dart apps: https://github.com/rrousselGit/riverpod/issues/425
