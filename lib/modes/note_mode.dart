import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/widgets/chromatic_keyboard.dart';
import 'package:ml_2/widgets/module_list.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';
import 'mode.dart';

class NoteMode implements DeviceMode {
  final WidgetContext _context;
  final List<Widget> _children = [];  

  NoteMode(this._context) {
    _children.add(ChromaticKeyboard(_context, onNoteOn: _playNote, onNoteOff: _stopNote));
    _children.add(ModuleList(_context));
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
    log("step clear all pads");
    _context.sendMidi(allPadOff);
    for (final child in _children) {
      child.onFocus();
    }
  }

  void _playNote(int note, int velocity) {
    final module = _context.currentModule;
    const track = 1;
    final moduleId = module?.id;
    if (moduleId == null) {
      throw Exception("no current module!");
    }
    // use hardcode full velocity as Fire's pads not sensitive enough
    _context.sunvox.sendNote(track, moduleId, note, 128);
  }

  void _stopNote(int note) {
    final module = _context.currentModule;
    const track = 1;
    final moduleId = module?.id;
    if (moduleId == null) {
      throw Exception("no current module!");
    }
    _context.sunvox.sendNote(track, moduleId, sunvoxNoteOffCommand, 127);
  }
}
