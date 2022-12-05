import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/sequencer/pattern.dart';

import '../modifiers.dart';
import '../widgets/widget.dart';
import 'mode.dart';

class StepMode implements DeviceMode {
  final WidgetContext _context;

  StepMode(this._context);
  
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
    if (event.direction == ButtonDirection.Up) {
      return;
    }
    final pCount = _context.sunvox.patternCount;
    final List<SqPattern> patterns = [];
    for (int i = 0; i < pCount; i++) {
      final pat = _context.sunvox.getPattern(i);
      if (pat != null) {
        patterns.add(SqPattern.fromSunvox(pat));
      }      
    }
    print("Pattern first note: ${patterns.first.tracks.first.steps.first.noteAsString}");    
  }

  @override
  void paint() {
    
  }

  @override
  void onFocus() {
  }
}
