import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';

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
    final pCount = _context.sunvox.patternCount;
    log("step pad - patterns: $pCount");
    for (int i = 0; i < 1; i++) {
      final pat = _context.sunvox.getPattern(i);
      log("Pat [${pat?.id}] ${pat?.name}, track count: ${pat?.patternTrackCount} lines: ${pat?.patternLineCount}");
      log("Pat Data:\n${pat?.data.join('\n')}");
      // final note = pat?.data.first.events[3].note;
      // final noteStr = Pitch.fromMidiNumber(note ?? 0); //.toString().replaceAll("♯", "#");
      // log("note:$noteStr");
    }    
  }

  @override
  void paint() {
    
  }

  @override
  void onFocus() {
  }
}
