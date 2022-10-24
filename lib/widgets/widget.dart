import 'dart:typed_data';

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:ml_2/oled/screen.dart';
import 'package:riverpod/riverpod.dart';

import '../modifiers.dart';

abstract class Widget {
  void onButton(ButtonEvent event, Modifiers mods);
  void onPad(PadEvent event, Modifiers mods);
  void onDial(DialEvent event, Modifiers mods);

  void onFocus();
  void paint();
}

/// Signature of callbacks that have no arguments and return no data.
/// Same as from Flutter SDK
typedef VoidCallback = void Function();

class WidgetContext {
  final ProviderContainer container;
  final AlsaMidiDevice _midiDevice;
  final OledScreen screen;
  final LibSunvox sunvox;

  SVModule? currentModule;

  WidgetContext(this.container, this._midiDevice, this.screen, this.sunvox);

  void sendMidi(Uint8List midiData) => _midiDevice.send(midiData);

  void clearAllPads() => _midiDevice.send(allPadOff); // clear pads on each change of top-level mode
}
