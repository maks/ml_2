import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:riverpod/riverpod.dart';

import '../modifiers.dart';
import '../providers.dart';
import 'mode.dart';

class NoteMode implements DeviceMode {
  final LibSunvox _sunvox;
  final ProviderContainer _container;
  int _octave = 4;

  NoteMode(this._container, this._sunvox);

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    // TODO: implement onButton
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    // TODO: implement onDial
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      final moduleMode = _container.read(moduleModeProvider);

      // final note = 10 + (event.row * 16) + event.column;
      final note = _noteFromPadIndex(_octave, event.row * 16 + event.column);

      log("note:$note");

      final module = moduleMode.value?.currentModule;
      const track = 1;
      final moduleId = module?.id;
      if (moduleId == null) {
        throw Exception("no current module!");
      }
      _sunvox.sendEvent(track, moduleId, note, 127);
    }
  }

  @override
  void onUpdate(AlsaMidiDevice midiDev) {}

  @override
  void onFocus(AlsaMidiDevice midiDev) {
    log("step clear all pads");
    midiDev.send(allPadOff);
    _paintPadsKeyboard(midiDev);
  }

  static const firstBlackRow = 32;
  static const firstWhiteRow = 48;
  static const blackKeys = [0, 1, 3, 0, 6, 8, 10, 0, 13, 15, 0, 18, 20, 22, 0, 25];
  static const whitekeys = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26];

  /// chromatic keyboard, shown in Note mode
  void _paintPadsKeyboard(AlsaMidiDevice midiDev) {
    const blackKeyColour = PadColor(0, 0, 80);
    const whiteKeyColour = PadColor(80, 80, 100);
    for (var i = firstBlackRow; i < firstWhiteRow; i++) {
      if (blackKeys[i % 16] != 0) {
        midiDev.send(colorPad(i ~/ 16, i % 16, blackKeyColour));
      }
    }
    for (var i = firstWhiteRow; i < firstWhiteRow + 16; i++) {
      midiDev.send(colorPad(i ~/ 16, i % 16, whiteKeyColour));
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
