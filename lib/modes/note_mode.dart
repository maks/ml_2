import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/chromatic_keyboard.dart';
import 'package:ml_2/widgets/module_list.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';
import 'mode.dart';
import 'play_note.dart';

class NoteMode implements DeviceMode {
  final WidgetContext _context;
  final List<Widget> _children = [];

  NoteMode(this._context) {
    _children.add(ChromaticKeyboard(
      _context,
      onNoteOn: (note, vel) => playNote(_context, note, vel),
      onNoteOff: (note) => stopNote(_context, note),
    ));
    _children.add(ModuleList(_context, onlyInstruments: true));
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    for (final child in _children) {
      child.onButton(event, mods);
    }
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    for (final child in _children) {
      child.onDial(event, mods);
    }
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    for (final child in _children) {
      child.onPad(event, mods);
    }
  }

  @override
  void paint() {
    for (final child in _children) {
      child.paint();
    }
  }

  @override
  void onFocus() {
    for (final child in _children) {
      child.onFocus();
    }
  }
}
