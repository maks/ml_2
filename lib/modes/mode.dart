
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';

abstract class DeviceMode extends Widget {
  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    // empty default implementation
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    // empty default implementation
  }

  @override
  void onFocus() {
    // empty default implementation
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    // empty default implementation
  }

  @override
  void paint() {
    // empty default implementation
  }
}
