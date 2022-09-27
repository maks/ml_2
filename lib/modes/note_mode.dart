import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';

import '../modifiers.dart';
import 'modes.dart';

class NoteMode implements DeviceMode {
  final LibSunvox _sunvox;

  NoteMode(this._sunvox);

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
      final note = 10 + (event.row * 8) + event.column;
      log("note:$note");
      final moduleId = _sunvox.findModuleByName("Kicker");
      const track = 1;
      _sunvox.sendEvent(track, moduleId, note, 127);
    }
  }

  @override
  void onUpdate(AlsaMidiDevice midiDev) {
    
  }

  @override
  void onFocus(AlsaMidiDevice midiDev) {
    log("step clear all pads");
    midiDev.send(allPadOff);
  }
}
