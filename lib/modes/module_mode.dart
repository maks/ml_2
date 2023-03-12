import 'dart:math' as math;

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/extensions.dart';
import 'package:ml_2/pads.dart';
import 'package:ml_2/widgets/widget.dart';

import 'package:bonsai/bonsai.dart';
import '../modifiers.dart';
import '../widgets/chromatic_keyboard.dart';
import '../widgets/module_list.dart';
import '../widgets/oled_listscreen.dart';
import 'mode.dart';
import 'play_note.dart';

/// uses the "drum mode" button
class ModuleMode implements DeviceMode {
  final WidgetContext _context;
  final List<Widget> _children = [];

  int _controllerPage = 0;
  bool _browser = false;

  int dialDebounce = 0;
  DialDirection? dialDebounceDir;

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
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    final children = List<Widget>.from(_children);
    for (final child in children) {
      child.onButton(event, mods);
    }

    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.Browser) {
        _toggleBrowserMode();
      }
      if (event.type == ButtonType.PatternUp) {
        final controllersCount = _context.currentModule?.controllers.length ?? 0;
        log("cntrl count: $controllersCount");
        _controllerPage = math.min((controllersCount / 3).floor(), _controllerPage + 1);
      }
      if (event.type == ButtonType.PatternDown) {
        _controllerPage = math.max(0, _controllerPage - 1);
      }
    } else {
      if (event.type == ButtonType.PatternUp || event.type == ButtonType.PatternDown) {
        _showControllersPageOnOled();
      }
    }
    log("controller page: $_controllerPage");
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    for (final child in _children) {
      child.onDial(event, mods);
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
      dialDebounce = 0;
    }

    if (event.direction == DialDirection.Left || event.direction == DialDirection.Right) {
      dialDebounceDir ??= event.direction;
      if (dialDebounceDir != event.direction) {
        dialDebounce = 0; //reset debounce
        dialDebounceDir = event.direction;
      }
      dialDebounce++;
      if (dialDebounce > 3) {
        dialDebounce = 0; //reset debounce

        (event.direction == DialDirection.Left) ? controller.dec(event.velocity) : controller.inc(event.velocity);
        final modId = _currentModule?.id;
        if (modId == null) {
          log("missing module id for controller value set");
          return;
        }
      }
    }
    //_context.screen.drawContent([controller.name, "${controller.displayValue ?? controller.value}"], large: true);
    _showControllersPageOnOled();
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    for (final child in _children) {
      child.onPad(event, mods);
    }
    // TODO: for now workaround for detecting module pad change
    if (padIndexFrom(event.column, event.row) < 31) {
      _controllerPage = 0; //reset controller page
    }
  }

  @override
  void paint() {
    for (final child in _children) {
      child.paint();
    }

    // show browser mode on/off LED
    final browserButtonLED = _browser ? ButtonLedColor.color1.index : ButtonLedColor.off.index;
    _context.sendMidi(ButtonControls.buttonOn(ButtonCode.browser, browserButtonLED));
  }

  void _toggleBrowserMode() {
    _browser = !_browser;
    if (_browser) {
      final browserListWidget = OledListScreenWidget(_context, AllModulesListProvider(), _browserOnModuleSelected);
      _children.add(browserListWidget);
      browserListWidget.onFocus();
    } else {
      _children.removeWhere((element) => element is OledListScreenWidget);
      // TODO: for now manually clear oled screen here
      _context.screen.clear();
    }
  }

  void _browserOnModuleSelected(String type, void _) {
    log("==> create new mod: $type");
    final nuModule = _context.sunvox.createModule(type, type);

    if (nuModule != null) {
      // for now just automatically connect to output module
      nuModule.connectToModule(0);
      onFocus(); // TODO: temp hack to force module list to refresh modules list
      _context.currentModule = nuModule;
      _toggleBrowserMode(); // leave browser mode after adding new module
    } else {
      throw Exception("could not create module $type");
    }
    //TODO: manual paint call until periodic calls to paint is implemented
    paint();
  }

  void _showControllersPageOnOled() {
    final controllerNames = <String>[];
    final controllers = _context.currentModule?.controllers;
    if (controllers == null) {
      log("no current controller");
      return;
    }
    for (int i in [0, 1, 2]) {
      final controllerIndex = i + (_controllerPage * 3);
      if (controllerIndex >= controllers.length) {
        continue;
      }
      final controller = controllers[controllerIndex];
      controllerNames.add("${_controllerAbrv(controller.name)} ${controller.displayValue.toString().truncate(4)}");
    }
    _context.screen.drawContent(controllerNames, large: true);
  }

  @override
  void onFocus() {
    for (final child in _children) {
      child.onFocus();
    }
  }

  String _controllerAbrv(String name) {
    if (controllerAbbreviations[name] != null) {
      return controllerAbbreviations[name]!;
    } else {
      log("missing abrv:$name");
      return name.truncate(3);
    }
  }
}

class AllModulesListProvider implements ListItemProvider {
  @override
  String? itemName(int index) => index < allModuleTypes.length ? allModuleTypes.elementAt(index) : null;
}

const controllerAbbreviations = {
  "Volume": "VOL ",
  "Attack": "ATK ",
  "Release": "REL ",
  "Sustain": "SUS ",
  "Panning": "PAN ",
  "Waveform": "WAV ",
  "Exponential envelope": "ENV ",
  "Duty cycle": "DUTY",
  "Osc2": "OSX2",
  "Filter": "FLTR",
  "F.freq": "FLFR",
  "F.resonance": "FLRE",
  "F.exponential freq": "FLEF",
  "F.attack": "FLAK",
  "F.release": "FLRL",
  "F.envelope": "FLEN",
  "Polyphony": "POLY",
  "Wet": "WET ",
  "Dry": "DRY ",
  "Feedback": "FDBK",
  "Damp": "DAMP",
  "Type": "TYPE",
  "BPM (Beats Per Minute)": "BPM ",
  "TPL (Ticks Per Line)": "TPL  ",
  "Input module": "INMD",
  "Play patterns": "PLPT",
  "Mode": "MODE",
  "H.type": "HTYP",
  "H.freq": "HFRQ",
  "H.volume": "HVOL",
  "H.width": "HWDT",
  "Spectrum resolution": "SRES",
  "Harmonic": "HARM",
  "Room Size": "RMSZ",
  "Tone": "TONE",
  "Noise": "NOIS",
  "Osc2 volume": "OC2V",
  "Osc2 mode": "OC2M",
  "Osc2 phase": "OC2P",
  "Side-chain input": "SCIN",
  "Threshold": "THRS",
  "Slope": "SLOP",
  "Channels": "CHAN",
  "Set phase": "SETP",
  "Frequency unit": "FRQU",
  "Exponential amplitude": "EXPA",
  "Amplitude": "AMPL",
  "Freq": "FREQ",
  "Delay": "DELY",
  "Right channel offset": "RCHN",
  "Delay unit": "DLYU",
  "Input -> Operator #": "INOP",
  "Input -> Custom waveform": "INCW",
  "ADSR smooth transitions": "ADSR",
  "Noise filter (32768 - OFF)": "NOFL",
  "1 Volume": "1VOL",
  "2 Volume": "2VOL",
  "3 Volume": "3VOL",
  "4 Volume": "4VOL",
  "5 Volume": "5VOL",
  "1 Attack": "1ATK",
  "2 Attack": "2ATK",
  "3 Attack": "3ATK",
  "4 Attack": "4ATK",
  "5 Attack": "5ATK",
  "1 Decay": "1DCY",
  "2 Decay": "2DCY",
  "3 Decay": "3DCY",
  "4 Decay": "4DCY",
  "5 Decay": "5DCY",
  "1 Sustain level": "1SUS",
  "2 Sustain level": "2SUS",
  "3 Sustain level": "3SUS",
  "4 Sustain level": "4SUS",
  "5 Sustain level": "5SUS",
  "1 Release": "1REL",
  "2 Release": "2REL",
  "3 Release": "3REL",
  "4 Release": "4REL",
  "5 Release": "5REL",
};
