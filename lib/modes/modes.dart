import 'package:midi/midi.dart';

import 'package:dart_fire_midi/dart_fire_midi.dart';

import '../modifiers.dart';

abstract class DeviceMode {
  void onButton(ButtonEvent event, Modifiers mods);
  void onPad(PadEvent event, Modifiers mods);
  void onDial(DialEvent event, Modifiers mods);

  void onUpdate(AlsaMidiDevice midiDev);
}
