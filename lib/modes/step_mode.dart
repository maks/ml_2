import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/extensions.dart';
import 'package:ml_2/providers.dart';
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
      log("page: $_page");
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
    log("Track:$track Step:$step Note:$note [$_patternLength]");
    _pressedStepNote = note;
  }

  @override
  void paint() {
    _context.screen.drawContent([_pressedStepNote], large: true);
    
    final pat = _context.sunvox.getPattern(0); //TODO: hardcoded 1st pattern for now
    final line = _context.container.read(transportControlsProvider).line % (pat?.patternLineCount ?? 1);

    _paintPadSteps(line);
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
    // log("read sunvox patterns:\n ${patterns.length}");
    // log("Pattern 1:\n${patterns.first}");
   
    return patterns;
  }

  void _paintPadSteps(int line) {
    _context.sendMidi(allPadOff);

    final patterns = _getPatterns();
    final pattern = patterns.first; //TODO: use selected pattern

    for (var t = 0; t < pattern.tracks.length; t++) {
      final track = pattern.tracks[t];
      for (int s = 0; s < 16; s++) {
        final step = track.steps[s];
        final color = line == s ? PadColor(0, 0, 50) : PadColor(step.note, step.note, step.note);
        if (step.note > 11) {
          _context.sendMidi(colorPad(t, s, color));
        }
      }
    }
  }
}
