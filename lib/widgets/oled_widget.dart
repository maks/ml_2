import 'package:dart_fire_midi/dart_fire_midi.dart';

import '../modifiers.dart';
import 'widget.dart';

abstract class OledWidget implements Widget {
  @override
  void onButton(ButtonEvent event, Modifiers mods) {}

  @override
  void onDial(DialEvent event, Modifiers mods) {}

  @override
  void onFocus() {}

  @override
  void onPad(PadEvent event, Modifiers mods) {}

  @override
  void paint() {}
}
