import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/widgets/widget.dart';

import '../modifiers.dart';
import '../widgets/chromatic_keyboard.dart';
import '../widgets/module_list.dart';
import '../widgets/oled_listscreen.dart';
import 'mode.dart';
import 'play_note.dart';

/// uses the "drum mode" button
class ModuleMode implements DeviceMode {
  final WidgetContext _context;
  late final OledListScreenWidget _browserListWidget;

  int _controllerPage = 0;
  bool _browser = false;

  final List<Widget> _children = [];

  SVModule? get _currentModule => _context.sunvox.getModule(_context.currentModule?.id ?? 0);

  ModuleMode(this._context) {
    _children.add(
      ChromaticKeyboard(
        _context,
        onNoteOn: (note, vel) => playNote(_context, note, vel),
        onNoteOff: (note) => stopNote(_context, note),
      ),
    );
    _children.add(ModuleList(_context));
    _browserListWidget = OledListScreenWidget(_context.screen, AllModulesListProvider(), _browserOnModuleSelected);
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) { 
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.Browser) {
        _browser = !_browser;
        if (_browser) {
          _browserListWidget.onFocus();
        } else {
          paint();
        }
      }
      if (_browser) {
        _browserListWidget.onButton(event, mods);
        return;
      }

      if (event.type == ButtonType.PatternUp) {
        _controllerPage = _controllerPage + 1;
      }
      if (event.type == ButtonType.PatternDown) {
        _controllerPage = _controllerPage - 1;
      }
     
    }
    log("controller page: $_controllerPage");
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    if (_browser) {
      _browserListWidget.onDial(event, mods);
      return;
    }

    int dialIndex = 0;
    if (event.type == DialType.Filter) {
      dialIndex = 1;
    }
    if (event.type == DialType.Resonance) {
      dialIndex = 2;
    }

    final controllers = _context.currentModule?.controllers;
    if (controllers == null) {
      log("no current controller");
      return;
    }
    final controllerIndex = dialIndex + (_controllerPage * 3);
    late final SVModuleController controller;
    if (controllerIndex < controllers.length) {
      controller = controllers[controllerIndex];
    } else {
      log("dial controller out of range: $controllerIndex");
      return;
    }
    if (event.direction == DialDirection.TouchOn) {
      // na just update screen at end of method
    }

    if (event.direction == DialDirection.Left || event.direction == DialDirection.Right) {     
      (event.direction == DialDirection.Left) ? controller.dec(event.velocity) : controller.inc(event.velocity);
      final modId = _currentModule?.id;
      if (modId == null) {
        log("missing module id for controller value set");
        return;
      }
    }
    _context.screen.drawContent([controller.name, "${controller.displayValue ?? controller.value}"], large: true);
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

    // show browser mode on/off LED
    final ButtonLedColor browserButtonState = _browser ? ButtonLedColor.color1 : ButtonLedColor.off;
    _context.sendMidi(ButtonControls.buttonOn(ButtonCode.browser, browserButtonState.index));
  }

  void _browserOnModuleSelected(String type, void _) {
    log("==> create new mod: $type");
    final nuModule = _context.sunvox.createModule(type, type);

    if (nuModule != null) {
      // for now just automatically connect to output module
      nuModule.connectToModule(0);
      onFocus(); // TODO: temp hack to force module list to refresh modules list
      _context.currentModule = nuModule;
      _browser = false; // leave browser mode after adding new module
    } else {
      throw Exception("could not create module $type");
    }
    //TODO: manual paint call until periodic calls to paint is implemented
    paint();
  }

  @override
  void onFocus() {
    log("step clear all pads");
    _context.sendMidi(allPadOff);
    for (final child in _children) {
      child.onFocus();
    }
  }
}

class AllModulesListProvider implements ListItemProvider {
  @override
  String? itemName(int index) => index < allModuleTypes.length ? allModuleTypes.elementAt(index) : null;
}
