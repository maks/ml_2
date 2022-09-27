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

      final note = 10 + (event.row * 8) + event.column;
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
  void onUpdate(AlsaMidiDevice midiDev) {
    
  }

  @override
  void onFocus(AlsaMidiDevice midiDev) {
    log("step clear all pads");
    midiDev.send(allPadOff);
  }
}
