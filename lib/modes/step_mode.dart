import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:midi/midi.dart';

import '../modifiers.dart';
import 'modes.dart';

class StepMode implements DeviceMode {
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
    // TODO: implement onPad
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
