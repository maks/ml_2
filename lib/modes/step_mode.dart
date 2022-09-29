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
    // TODO: implement onPad
  }

  @override
  void paint() {
    
  }

  @override
  void onFocus() {
    log("step clear all pads");
    _context.sendMidi(allPadOff);
  }
}
