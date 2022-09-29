import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';
import '../pads.dart';
import 'mode.dart';

/// uses the "drum mode" button
class ModuleMode implements DeviceMode {
  final WidgetContext _context;

  int _selectedModuleIndex = 0;

  SVModule? get _currentModule => _context.sunvox.getModule(_selectedModuleIndex);

  ModuleMode(this._context) {
    _context.currentModule = _currentModule;
  }

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
    _context.currentModule = _currentModule;

    final module = _context.sunvox.getModule(_selectedModuleIndex);
    log("pad[$_selectedModuleIndex] ${module?.name}");
    _context.screen.drawContent([module?.name ?? "Un-named"], large: true);
  }

  @override
  void paint() {
    _showModulesOnPads();
  }

  void _showModulesOnPads() {
    for (var i = 0; i < _context.sunvox.moduleSlotsCount; i++) {
      final module = _context.sunvox.getModule(i);
      if (module == null) {
        continue;
      }
      //log("[$i] ${module.name} [${module.color}] inputs: ${module.inputs} outputs: ${module.outputs}");
      final int row = i ~/ 16;
      final int col = i % 16;
      _context.sendMidi(colorPad(row, col, fromSVColor(module.color)));
    }
  }
  
  @override
  void onFocus() {
    _showModulesOnPads();
  }
}
