import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:ml_2/oled/screen.dart';

import '../modifiers.dart';
import '../pads.dart';
import 'mode.dart';

/// uses the "drum mode" button
class ModuleMode implements DeviceMode {
  final LibSunvox _sunvox;
  final Screen screen;

  int _selectedModuleIndex = 0;

  SVModule? get currentModule => _sunvox.getModule(_selectedModuleIndex);

  ModuleMode(this._sunvox, this.screen);

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
    _selectedModuleIndex = (event.row * 16) + event.column;
    final module = _sunvox.getModule(_selectedModuleIndex);
    log("pad[$_selectedModuleIndex] ${module?.name}");
    screen.drawContent([module?.name ?? "Un-named"], large: true);
  }

  @override
  void onUpdate(AlsaMidiDevice midiDev) {
    _showModulesOnPads(midiDev);
  }

  void _showModulesOnPads(AlsaMidiDevice midiDevice) {
    for (var i = 0; i < _sunvox.moduleSlotsCount; i++) {
      final module = _sunvox.getModule(i);
      if (module == null) {
        continue;
      }
      //log("[$i] ${module.name} [${module.color}] inputs: ${module.inputs} outputs: ${module.outputs}");
      final int row = i ~/ 16;
      final int col = i % 16;
      midiDevice.send(colorPad(row, col, fromSVColor(module.color)));
    }
  }
  
  @override
  void onFocus(AlsaMidiDevice midiDev) {
    _showModulesOnPads(midiDev);
  }
}
