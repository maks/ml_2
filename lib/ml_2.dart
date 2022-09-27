import 'dart:io';

import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:collection/collection.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;
import 'package:ml_2/modes/mode.dart';
import 'package:ml_2/transport_controls.dart';

import 'modes/module_mode.dart';
import 'modes/note_mode.dart';
import 'oled/screen.dart';
import 'modes/perform_mode.dart';
import 'modes/step_mode.dart';
import 'modifiers.dart';

class ML2 {
  late final LibSunvox _sunvox;
  late final AlsaMidiDevice _midiDevice;
  int _currentModeIndex = 0;
  List<DeviceMode> modes = [];

  DeviceMode get currentMode => modes[_currentModeIndex];

  Modifiers _modifiers = Modifiers.allOff();
  late final TransportControls _transportControls;
  final Screen _screen;

  ML2(this._screen, this._sunvox, this.modes);

  void playPause() {
    log("Play-Pause!");
    if (_transportControls.state == TransportState.playing) {
      _sunvox.pause();
      _transportControls.pause();
    } else if (_transportControls.state == TransportState.paused) {
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
    if (_transportControls.state == TransportState.stopped) {
      _transportControls.idle();
    } else {
      _transportControls.stop();
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

    // uncomment to light up top left grid button blue
    midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 10, 70)));

    // listen for all incoming midi messages from the Fire
    midiDev.receivedMessages.listen((event) {
      // log('input event: $event');
      _handleInput(FireInputEvent.fromMidi(event.data));
    });

    // initial state update
    log('init: update ui');
    _screen.drawHeading("Hello ML-2 :)");
    _updateUI();
  }

  void _handleInput(FireInputEvent event) {
    log("handleInput event: $event");
    if (event is ButtonEvent) {
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
          case ButtonType.PatterDown:
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
            _currentModeIndex = 0;
            currentMode.onFocus(_midiDevice);
            break;
          case ButtonType.Note:
            _currentModeIndex = 1;
            currentMode.onFocus(_midiDevice);
            break;
          case ButtonType.Drum:
            _currentModeIndex = 2;
            currentMode.onFocus(_midiDevice);
            break;
          case ButtonType.Perform:
            _currentModeIndex = 3;
            currentMode.onFocus(_midiDevice);
            break;
          case ButtonType.Shift:
            _modifiers = _modifiers.copyWith(shift: false);
            _midiDevice.send(ButtonControls.buttonOn(ButtonCode.shift, 1));
            break;
          case ButtonType.Alt:
            _modifiers = _modifiers.copyWith(alt: true);
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
            _midiDevice.send(ButtonControls.buttonOff(ButtonCode.shift));
            break;
          case ButtonType.Alt:
            _modifiers = _modifiers.copyWith(alt: false);
            _midiDevice.send(ButtonControls.buttonOff(ButtonCode.alt));
            break;
          default: //NA
            break;
        }
      }
    }
    if (event is PadEvent) {      
      currentMode.onPad(event, _modifiers);
    }
    if (event is DialEvent) {
      log("dial: ${event.type} [${event.direction}] ${event.velocity}");

      currentMode.onDial(event, _modifiers);
    }
    //TODO: need to call on timer, but for now just call only after events
    _updateUI();
  }

  void _updateUI() {
    for (final b in [ButtonCode.step, ButtonCode.note, ButtonCode.drum, ButtonCode.perform]) {
      _midiDevice.send(ButtonControls.buttonOn(b, 0));
    }
    log("update ui: $currentMode");
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
    currentMode.onUpdate(_midiDevice);

    _repaintOLED();
  }

  void _repaintOLED() {
    _midiDevice.send(fire.sendBitmap(_screen.bitmapData));
    _screen.clear();
  }

  void shutdown() {
    log("ml 2 shutting down");
    _midiDevice.disconnect();
    log("midi device disconnected");
  }
}
