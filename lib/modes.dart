import 'package:dart_fire_midi/dart_fire_midi.dart';

import 'modifiers.dart';

abstract class DeviceMode {
  void onButton(ButtonEvent event, Modifiers mods);
  void onPad(PadEvent event, Modifiers mods);
  void onDial(DialEvent event, Modifiers mods);

  void onUpdate();
}

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
  void onUpdate() {
    // TODO: implement onUpdate
  }
}

class NoteMode implements DeviceMode {
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
  void onUpdate() {
    // TODO: implement onUpdate
  }
}

/// uses the "drum mdoe" button
class ModuleMode implements DeviceMode {
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
  void onUpdate() {
    // TODO: implement onUpdate
  }
}

class PerformMode implements DeviceMode {
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
  void onUpdate() {
    // TODO: implement onUpdate
  }
}
