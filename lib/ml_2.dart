import 'dart:async';
import 'dart:io';

import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:collection/collection.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;
import 'package:ml_2/modes/mode.dart';
import 'package:ml_2/transport_controls.dart';
import 'package:ml_2/widgets/widget.dart';
import 'package:riverpod/riverpod.dart';

import 'modes/module_mode.dart';
import 'modes/note_mode.dart';
import 'oled/screen.dart';
import 'modes/perform_mode.dart';
import 'modes/step_mode.dart';
import 'modifiers.dart';
import 'providers.dart';
import 'volume.dart';

class ML2 {
  final ProviderContainer _container;
  late final LibSunvox _sunvox;
  late final AlsaMidiDevice _midiDevice;
  late final Timer _ticker;
  int _currentModeIndex = 0;
  List<DeviceMode> modes = [];
  int _lastLine = 0;
  bool _dirty = false;

  final _volume = Volume(64); // init to 25%

  DeviceMode get currentMode => modes[_currentModeIndex];

  set _setCurrentMode(int modeIndex) {
    _currentModeIndex = modeIndex;
    _context.clearAllPads();
    currentMode.onFocus();
  }

  Modifiers _modifiers = Modifiers.allOff();
  late final TransportControls _transportControls;
  late final OledScreen _screen;
  late final WidgetContext _context;

  ML2(this._container);

  Future<void> init() async {
    _sunvox = await _container.read(sunvoxProvider.future);
    _screen = _container.read(screenProvider);

    fireInit();

    _context = WidgetContext(_container, _midiDevice, _screen, _sunvox);

    modes = [StepMode(_context), NoteMode(_context), ModuleMode(_context), PerformMode(_context)];

    // lets go for 30fps (32ms ticker)
    _ticker = Timer.periodic(Duration(milliseconds: 32), (timer) {
      if (timer.isActive) {
        _tick();
      }
    });
    print("ticking===");
  }

  void playPause() {
    log("Play-Pause!");
    if (_transportControls.isPlaying) {
      _sunvox.pause();
      _transportControls.pause();
    } else if (_transportControls.isPaused) {
      _sunvox.resume();
      _transportControls.play();
    } else {
      _sunvox.playFromStart();
      _transportControls.play();
    }
  }

  void stop() {
    log("Stop!");
    _sunvox.stop();
    if (_transportControls.isStopped) {
      _transportControls.idle();
    } else {
      _transportControls.stop();
      _lastLine = 0;
    }
  }

  void record() {
    log("Record!");
    // _sunvox.record();
    _transportControls.record();
  }

  Future<void> fireInit() async {
    final midiDevices = AlsaMidiDevice.getDevices();
    if (midiDevices.isEmpty) {
      log('missing akai fire controller');
      exit(1);
    }

    // find first Akai Fire controller
    final midiDev = midiDevices.firstWhereOrNull((dev) => dev.name.contains('FL STUDIO'));
    if (midiDev == null) {
      throw Exception('missing Akai Fire device');
    }
    _midiDevice = midiDev;

    if (!(await midiDev.connect())) {
      log('failed to connect to Akai Fire device');
      return;
    } else {
      print("Connected to Akai Fire device !");
    }

    _transportControls = TransportControls();

    midiDev.send(fire.allOffMessage);
    log('init: all off');

    // light up top left grid button blue to show init state
    midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 10, 70)));

    // listen for all incoming midi messages from the Fire
    midiDev.receivedMessages.listen((event) {
      _handleInput(FireInputEvent.fromMidi(event.data));
    });

    // initial state update
    log('init: update ui');
    _screen.drawContent(["ML-2 :-)"], large: true);
    //_updateUI();
  }

  void _handleInput(FireInputEvent event) {
    //log("handleInput event: $event");
    bool isModifier = false;
    if (event is ButtonEvent && event is! PadEvent) {
      if (event.direction == ButtonDirection.Down) {
        switch (event.type) {
          case ButtonType.Play:
            playPause();
            break;
          case ButtonType.Stop:
            stop();
            break;
          case ButtonType.PatternUp:
            // TODO: Handle this case.
            break;
          case ButtonType.PatternDown:
            // TODO: Handle this case.
            break;
          case ButtonType.Browser:
            // TODO: Handle this case.
            break;
          case ButtonType.GridLeft:
            // TODO: Handle this case.
            break;
          case ButtonType.GridRight:
            // TODO: Handle this case.
            break;
          case ButtonType.BankSelect:
            // TODO: Handle this case.
            break;
          case ButtonType.MuteButton1:
            // TODO: Handle this case.
            break;
          case ButtonType.MuteButton2:
            // TODO: Handle this case.
            break;
          case ButtonType.MuteButton3:
            // TODO: Handle this case.
            break;
          case ButtonType.MuteButton4:
            // TODO: Handle this case.
            break;
          case ButtonType.Step:
            _setCurrentMode = 0;
            break;
          case ButtonType.Note:
            _setCurrentMode = 1;
            break;
          case ButtonType.Drum:
            _setCurrentMode = 2;
            break;
          case ButtonType.Perform:
            _setCurrentMode = 3;
            break;
          case ButtonType.Shift:
            _modifiers = _modifiers.copyWith(shift: true);
            isModifier = true;
            _midiDevice.send(ButtonControls.buttonOn(ButtonCode.shift, 1));
            break;
          case ButtonType.Alt:
            _modifiers = _modifiers.copyWith(alt: true);
            isModifier = true;
            _midiDevice.send(ButtonControls.buttonOn(ButtonCode.alt, 1));
            break;
          case ButtonType.Pattern:
            // TODO: Handle this case.
            break;
          case ButtonType.Record:
            record();
            break;
          case ButtonType.Volume:
            // TODO: Handle this case.
            break;
          case ButtonType.Pan:
            // TODO: Handle this case.
            break;
          case ButtonType.Filter:
            // TODO: Handle this case.
            break;
          case ButtonType.Resonance:
            // TODO: Handle this case.
            break;
          case ButtonType.Select:
            // TODO: Handle this case.
            break;
          case ButtonType.Pad:
            // TODO: Handle this case.
            break;
        }
      } else {
        switch (event.type) {
          case ButtonType.Shift:
            _modifiers = _modifiers.copyWith(shift: false);
            isModifier = true;
            _midiDevice.send(ButtonControls.buttonOff(ButtonCode.shift));
            break;
          case ButtonType.Alt:
            _modifiers = _modifiers.copyWith(alt: false);
            isModifier = true;
            _midiDevice.send(ButtonControls.buttonOff(ButtonCode.alt));
            break;
          default: //NA
            break;
        }
      }
      if (!isModifier) {
        currentMode.onButton(event, _modifiers);
      }
    }
    if (event is PadEvent) {
      currentMode.onPad(event, _modifiers);
    }
    if (event is DialEvent) {
      log("dial: ${event.type} [${event.direction}] ${event.velocity}");

      if (event.type == DialType.Volume) {
        (event.direction == DialDirection.Left) ? _volume.dec(event.velocity) : _volume.inc(event.velocity);
        _sunvox.volume = _volume.value;
        _screen.drawContent(["${_volume.value}"], large: true);
      } else {
        currentMode.onDial(event, _modifiers);
      }
    }
    _dirty = true;
  }

  void _tick() {
    if (_transportControls.isPlaying) {
      final line = _sunvox.currentLine;
      if (_lastLine != line) {
        _lastLine = line;
        print("line:$_lastLine");
        // _dirty = true;
      }
    }
    if (_dirty) {
    _updateUI();
      _dirty = false;
    }
  }

  void _updateUI() {
    for (final b in [ButtonCode.step, ButtonCode.note, ButtonCode.drum, ButtonCode.perform]) {
      _midiDevice.send(ButtonControls.buttonOn(b, 0));
    }
    // log("update ui: ${currentMode.runtimeType}");
    switch (currentMode.runtimeType) {
      case StepMode:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.step, 1));
        break;
      case NoteMode:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.note, 1));
        break;
      case ModuleMode:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.drum, 1));
        break;
      case PerformMode:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.perform, 1));
        break;
    }
    _transportControls.update(_midiDevice);
    currentMode.paint();

    _repaintOLED();
  }

  void _repaintOLED() {
    _midiDevice.send(fire.sendBitmap(_screen.bitmapData));
    _screen.clear();
  }

  void shutdown() {
    log("ML-2 shutting down...");
    _screen.drawContent(["Shutting down..."]);
    _midiDevice.send(fire.sendBitmap(_screen.bitmapData));
    _midiDevice.send(allOffMessage);
    _sunvox.shutDown();
    sleep(Duration(milliseconds: 500)); //short wait for all off mesg before disconnecting midi
    _midiDevice.disconnect();
    log("midi device disconnected");
  }
}
