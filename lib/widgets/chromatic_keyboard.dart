import 'dart:math';

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/widget.dart';
import 'package:tonic/tonic.dart';

import '../modifiers.dart';
import 'pad_widget.dart';

class ChromaticKeyboard extends PadWidget {
  final Function(int) onNoteOn;
  final Function(int) onNoteOff;
  final WidgetContext _context;
  int _octave = 4;

  static const firstBlackRow = 32;
  static const firstWhiteRow = 48;
  static const blackKeys = [0, 1, 3, 0, 6, 8, 10, 0, 13, 15, 0, 18, 20, 22, 0, 25];
  static const whitekeys = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26];

  ChromaticKeyboard(this._context, {required this.onNoteOn, required this.onNoteOff});

  @override
  void onPad(PadEvent event, Modifiers mods) {
    final index = _noteFromPadIndex(_octave, event.row * 16 + event.column);
    if (event.direction == ButtonDirection.Down) {
      onNoteOn(index);
      _context.screen.clear();
      // use a char thats available in the simple font used for Oled canvas drawing
      final pitch = Pitch.fromMidiNumber(index).toString().replaceAll("♯", "#");
      _context.screen.drawContent([pitch], large: true);
    } else {
      onNoteOff(index);
    }
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.GridLeft) {
        _octave = max(_octave - 1, 0);
      } else if (event.type == ButtonType.GridRight) {
        _octave = min(_octave + 1, 7);
      }
      _context.screen.clear();
      _context.screen.drawContent(["Octave $_octave"], large: true);
    }
  }

  @override
  void paint() {
    _paintPadsKeyboard();
  }

  /// chromatic keyboard, shown in Note mode
  void _paintPadsKeyboard() {
    const blackKeyColour = PadColor(0, 0, 80);
    const whiteKeyColour = PadColor(80, 80, 100);
    for (var i = firstBlackRow; i < firstWhiteRow; i++) {
      if (blackKeys[i % 16] != 0) {
        _context.sendMidi(colorPad(i ~/ 16, i % 16, blackKeyColour));
      }
    }
    for (var i = firstWhiteRow; i < firstWhiteRow + 16; i++) {
      _context.sendMidi(colorPad(i ~/ 16, i % 16, whiteKeyColour));
    }
  }

  // work out note from chromatic keyboard displayed on bottom 2 rows of pads
  int _noteFromPadIndex(int octave, int index) {
    int midiNote = 0;
    final octaveStartingNote = (octave * 12) % 128;

    if (index <= firstBlackRow) {
      return 0;
    }

    if (index >= firstBlackRow && index < firstWhiteRow) {
      final noteOffset = blackKeys[index % 16];
      if (noteOffset == 0) {
        return 0;
      }
      midiNote = octaveStartingNote + noteOffset;
    } else {
      midiNote = octaveStartingNote + whitekeys[index % 16];
    }
    return midiNote;
  }
}
