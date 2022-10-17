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
  int _controllerPage = 0;

  SVModule? get _currentModule => _context.sunvox.getModule(_selectedModuleIndex);

  ModuleMode(this._context) {
    _context.currentModule = _currentModule;
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.PatternUp) {
        _controllerPage = _controllerPage + 1;
      }
      if (event.type == ButtonType.PatternDown) {
        _controllerPage = _controllerPage - 1;
      }
    }
    log("controller page: $_controllerPage");
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    int dialIndex = 0;
    if (event.type == DialType.Filter) {
      dialIndex = 1;
    }
    if (event.type == DialType.Resonance) {
      dialIndex = 2;
    }

    final controllers = _context.currentModule?.controllers;
    if (controllers == null) {
      log("no current controller");
      return;
    }
    final controllerIndex = dialIndex + (_controllerPage * 3);
    late final SVModuleController controller;
    if (controllerIndex < controllers.length) {
      controller = controllers[controllerIndex];
    } else {
      log("dial controller out of range: $controllerIndex");
      return;
    }
    if (event.direction == DialDirection.TouchOn) {
      // na just update screen at end of method
    }

    if (event.direction == DialDirection.Left || event.direction == DialDirection.Right) {     
      (event.direction == DialDirection.Left) ? controller.dec(event.velocity) : controller.inc(event.velocity);
      final modId = _currentModule?.id;
      if (modId == null) {
        log("missing module id for controller value set");
        return;
      }
    }
    _context.screen.drawContent([controller.name, "${controller.displayValue ?? controller.value}"], large: true);
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
