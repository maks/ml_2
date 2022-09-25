import 'dart:io';

import 'package:bonsai/bonsai.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:collection/collection.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;
import 'package:ml_2/modes.dart';
import 'package:ml_2/providers.dart';
import 'package:ml_2/transport_controls.dart';
import 'package:riverpod/riverpod.dart';


class ML2 {
  late final LibSunvox _sunvox;
  late final AlsaMidiDevice _midiDevice;
  DeviceMode _globalMode = StepMode();
  late final TransportControls _transportControls;
  final ProviderContainer _container;

  ML2(this._container);

  Future<void> sunvoxInit() async {
    log("cwd: ${Directory.current}");
    _sunvox = LibSunvox(0, "./sunvox.so");
    final v = _sunvox.versionString();
    log('sunvox lib version: $v');

    const filename = "song01.sunvox";
    // const filename = "default1.sunvox";
    await _sunvox.load(filename);
    // or as data using Dart's file ops
    // final data = File(filename).readAsBytesSync();

    _sunvox.volume = 256;

    log("project name: ${_sunvox.projectName}");
    log("modules: ${_sunvox.moduleSlotsCount}");
  }

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
    _transportControls.stop();
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
    }

    _transportControls = TransportControls();

    midiDev.send(fire.allOffMessage);
    log('init: all off');

    // uncomment to light up top left grid button blue
    midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 10, 70)));

    midiDev.receivedMessages.listen((event) {
      // log('input event: $event');
      _handleInput(FireInputEvent.fromMidi(event.data));
    });

    _showModulesOnPads(midiDev);

    _updateUI();
  }

  void _showModulesOnPads(AlsaMidiDevice midiDevice) {
    for (var i = 0; i < _sunvox.moduleSlotsCount; i++) {
      final module = _sunvox.getModule(i);
      if (module == null) {
        continue;
      }
      log("[$i] ${module.name} [${module.color}] inputs: ${module.inputs} outputs: ${module.outputs}");
      final int row = i ~/ 16;
      final int col = i % 16;
      midiDevice.send(fire.colorPad(row, col, fromSVColor(module.color)));
    }
  }

  void _handleInput(FireInputEvent event) {
    log("handleInput event: ${event.runtimeType}");
    if (event is ButtonEvent) {
      if (event.dir == ButtonDirection.Down) {
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
            _globalMode = _container.read(stepModeProvider);
            break;
          case ButtonType.Note:
            _globalMode = _container.read(noteModeProvider);
            break;
          case ButtonType.Drum:
            _globalMode = _container.read(moduleModeProvider);
            break;
          case ButtonType.Perform:
            _globalMode = _container.read(perfomModeProvider);
            break;
          case ButtonType.Shift:
            // TODO: Handle this case.
            break;
          case ButtonType.Alt:
            // TODO: Handle this case.
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
      }
    }
    if (event is PadEvent) {
      if (event.dir == ButtonDirection.Down) {
        final note = 10 + (event.row * 8) + event.column;
        log("note:$note");
        final moduleId = _sunvox.findModuleByName("Kicker");
        const track = 1;
        _sunvox.sendEvent(track, moduleId, note, 127);
      }
    }
    if (event is DialEvent) {
      log("dial: ${event.type} [${event.dir}] ${event.velocity}");
    }
    //TODO: need to call on timer, but for now just call only after events
    _updateUI();
  }

  void _updateUI() {
    for (final b in [ButtonCode.step, ButtonCode.note, ButtonCode.drum, ButtonCode.perform]) {
      _midiDevice.send(ButtonControls.buttonOn(b, 0));
    }
    switch (_globalMode.runtimeType) {
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
  }

  void shutdown() {
    log("ml 2 shutting down");
    _midiDevice.disconnect();
    log("midi device disconnected");
  }
}

const padDimRatio = 3;
const divisor = (2 * padDimRatio);
PadColor fromSVColor(SVColor c) => fire.PadColor(c.r ~/ divisor, c.g ~/ divisor, c.b ~/ divisor);
