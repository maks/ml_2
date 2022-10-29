import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/extensions.dart';

import '../modifiers.dart';
import '../pads.dart';
import 'pad_widget.dart';
import 'widget.dart';

class ModuleList extends PadWidget {
  final WidgetContext _context;
  final instrumentModulesMap = <int, int>{};
  final bool onlyInstruments;

  int? activePadIndex;

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
    log("pad module:[${module?.id}] ${module?.name}");
    _context.screen.drawContent(["${module?.name}"], large: true);

    if (event.direction == ButtonDirection.Down) {
      if (mods.shift) {
        log("outputs:${module?.outputs.join(',')}");
        _context.clearAllPads();
        _showModulesOnPads(overrides: module?.outputs);

        final outModNames = module?.outputs.map((e) => _context.sunvox.getModule(e)?.name).whereType<String>().toList();

        if (outModNames != null) {
          // TODO: for now only show 2 because only 2 fit in large Font mode
          _context.screen.drawContent(["${module?.name.truncate(8)} >", ...outModNames.take(2)], large: true);
        }
        return;
      }

      // ONLY do module connect/disconnect when NOT in instrument-only mode as
      // this assumes that padIndex is always same as moduleId when in module mode
      // which is NOT true in instrumentOnly mode
      if (!onlyInstruments) {
        final eventPadIndex = padIndexFrom(event.column, event.row);

        if (activePadIndex != null && activePadIndex != eventPadIndex) {
          final activeModule = _context.sunvox.getModule(activePadIndex!);
          if (activeModule?.outputs.contains(eventPadIndex) ?? false) {
            print("DISCONNECT: ${activeModule?.name} -> $eventPadIndex");
            activeModule?.disconnectFromModule(eventPadIndex);
          } else {
            print("CONNECT: ${activeModule?.name} -> $eventPadIndex");
            activeModule?.connectToModule(eventPadIndex);
          }
        } else {
          // we don't ever want to connect output aka "0" to flow *into* anything else
          if (eventPadIndex != 0) {
            activePadIndex ??= eventPadIndex;
          }
        }
      }
    } else if (event.direction == ButtonDirection.Up) {
      _showModulesOnPads();
      if (activePadIndex == padIndexFrom(event.column, event.row)) {
        activePadIndex = null;
      }
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
