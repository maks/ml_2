import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';
import 'mode.dart';

class PerformMode implements DeviceMode {
  final WidgetContext _context;

  PerformMode(this._context);

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
    // TODO: implement onUpdate
  }
  
  @override
  void onFocus() {
    
  }
}
