import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/extensions.dart';
import 'package:ml_2/sequencer/pattern.dart';

import '../modifiers.dart';
import '../widgets/widget.dart';
import 'mode.dart';

class StepMode implements DeviceMode {
  final WidgetContext _context;

  String _pressedStepNote = "";
  int _page = 0;
  int _patternLength = 0;

  StepMode(this._context);
  
  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.GridLeft) {
        _page = _page.decrement();
      }
      if (event.type == ButtonType.GridRight) {
        _page = _page.increment((_patternLength % 16) + 1);
      }
      print("page: $_page");
    }
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    // TODO: implement onDial
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Up) {
      _pressedStepNote = "";
      return;
    }
    final patterns = _getPatterns();
    final track = event.row;
    final step = event.column + (16 * _page);
    //TODO: use selected pattern
    final note = patterns.first.tracks[track].steps[step].noteAsString;
    _patternLength = patterns.first.tracks.first.steps.length;
    print("Track:$track Step:$step Note:$note [$_patternLength]");
    _pressedStepNote = note;
  }

  @override
  void paint() {
    print("step mode paint()");
    _context.screen.drawContent([_pressedStepNote], large: true);
  }

  @override
  void onFocus() {}

  List<SqPattern> _getPatterns() {
    final pCount = _context.sunvox.patternCount;
    final List<SqPattern> patterns = [];
    for (int i = 0; i < pCount; i++) {
      final pat = _context.sunvox.getPattern(i);
      if (pat != null) {
        patterns.add(SqPattern.fromSunvox(pat));
      }
    }
    print("read sunvox patterns:\n $patterns");
    //print("Pattern first note: ${patterns.first.tracks.first.steps.first.noteAsString}");
   
    return patterns;
  }
}
