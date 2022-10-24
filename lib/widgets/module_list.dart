import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';

import '../modifiers.dart';
import '../pads.dart';
import 'pad_widget.dart';
import 'widget.dart';

class ModuleList extends PadWidget {
  final WidgetContext _context;
  final instrumentModulesMap = <int, int>{};
  final bool onlyInstruments;

  ModuleList(this._context, {this.onlyInstruments = false});

  @override
  void onPad(PadEvent event, Modifiers mods) {
    final index = event.row * 16 + event.column;
    if (index > 32) {
      return; //only first 2 rows
    }
    final moduleId = instrumentModulesMap[index] ?? 0;
    // log("pad $index -> $moduleId");
    final module = _context.sunvox.getModule(moduleId);
    _context.currentModule = module;
    log("pad ${module?.name}");
    _context.screen.drawContent(["${module?.name}"], large: true);
     
    if (event.direction == ButtonDirection.Down && mods.shift) {
      log("outputs:${module?.outputs.join(',')}");
      _context.clearAllPads();
      _showModulesOnPads(overrides: module?.outputs);
      return;
    } else if (event.direction == ButtonDirection.Up) {
      _showModulesOnPads();
    }
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.Select && mods.alt) {
        log("DELETE === ${_context.currentModule?.name}");
        _context.currentModule?.remove();
        _context.clearAllPads(); //force module list update
        _showModulesOnPads(); //force module list update
      }
    }
  }

  @override
  void onFocus() {
    _showModulesOnPads();
  }

  void _showModulesOnPads({List<int>? overrides}) {
    int j = 0;
    for (var i = 0; i < _context.sunvox.moduleSlotsCount; i++) {
      final module = _context.sunvox.getModule(i);
      if (module == null) {
        continue;
      }
      if (onlyInstruments && !module.isInstrument) {
        log("skip: ${module.name}");
        continue;
      }
      instrumentModulesMap[j++] = i;
    }
    int i = 0;
    for (final entry in instrumentModulesMap.entries) {
      final module = _context.sunvox.getModule(entry.value);
      if (module == null) {
        log("skip null mod $i");
        i++;
        continue;
      }
      if (overrides != null && !overrides.contains(i)) {
        i++;
        continue;
      }
      final int row = i ~/ 16;
      final int col = i % 16;
      _context.sendMidi(colorPad(row, col, fromSVColor(module.color)));
      i++;
    }
  }
}
