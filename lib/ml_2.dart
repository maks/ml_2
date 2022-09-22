import 'dart:io';

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:collection/collection.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;
import 'package:ml_2/transport_controls.dart';

enum GlobalMode { step, note, drum, perform }

class ML2 {
  late final LibSunvox _sunvox;
  late final AlsaMidiDevice _midiDevice;
  GlobalMode _globalMode = GlobalMode.step;
  late final TransportControls _transportControls;

  Future<void> sunvoxInit() async {
    print("cwd: ${Directory.current}");
    _sunvox = LibSunvox(0, "./sunvox.so");
    final v = _sunvox.versionString();
    print('sunvox lib version: $v');

    const filename = "song01.sunvox";
    // const filename = "default1.sunvox";
    await _sunvox.load(filename);
    // or as data using Dart's file ops
    // final data = File(filename).readAsBytesSync();

    _sunvox.volume = 256;

    print("project name: ${_sunvox.projectName}");
    print("modules: ${_sunvox.moduleSlotsCount}");
  }

  void play() {
    print("PLay!");
    _sunvox.play();
    _transportControls.play();
  }

  void record() {
    print("Record!");
    // _sunvox.record();
    _transportControls.record();
  }

  void stop() {
    print("Stop!");
    _sunvox.stop();
    _transportControls.stop();
  }

  Future<void> fireInit() async {
    final midiDevices = AlsaMidiDevice.getDevices();
    if (midiDevices.isEmpty) {
      print('missing akai fire controller');
      exit(1);
    }

    // find first Akai Fire controller
    final midiDev = midiDevices.firstWhereOrNull((dev) => dev.name.contains('FL STUDIO'));
    if (midiDev == null) {
      throw Exception('missing Akai Fire device');
    }
    _midiDevice = midiDev;

    if (!(await midiDev.connect())) {
      print('failed to connect to Akai Fire device');
      return;
    }

    _transportControls = TransportControls();

    midiDev.send(fire.allOffMessage);
    print('init: all off');

    // uncomment to light up top left grid button blue
    midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 10, 70)));

    midiDev.receivedMessages.listen((event) {
      //print('input event: $event');
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
      print("[$i] ${module.name} [${module.color}] inputs: ${module.inputs} outputs: ${module.outputs}");
      final int row = i ~/ 16;
      final int col = i % 16;
      midiDevice.send(fire.colorPad(row, col, fromSVColor(module.color)));
    }
  }

  void _handleInput(FireInputEvent event) {
    //print("event: ${event.runtimeType}");
    if (event is ButtonEvent) {
      //print("button: $event");
      if (event.dir == ButtonDirection.Down) {
        switch (event.type) {
          case ButtonType.Play:
            play();
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
            _globalMode = GlobalMode.step;
            break;
          case ButtonType.Note:
            _globalMode = GlobalMode.note;
            break;
          case ButtonType.Drum:
            _globalMode = GlobalMode.drum;
            break;
          case ButtonType.Perform:
            _globalMode = GlobalMode.perform;
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
        print("note:$note");
        final moduleId = _sunvox.findModuleByName("Kicker");
        const track = 1;
        _sunvox.sendEvent(track, moduleId, note, 127);
      }
    }
    //TODO: need to call on timer, but for now just call only after events
    _updateUI();
  }

  void _updateUI() {
    for (final b in [ButtonCode.step, ButtonCode.note, ButtonCode.drum, ButtonCode.perform]) {
      _midiDevice.send(ButtonControls.buttonOn(b, 0));
    }
    switch (_globalMode) {
      case GlobalMode.step:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.step, 1));
        break;
      case GlobalMode.note:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.note, 1));
        break;
      case GlobalMode.drum:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.drum, 1));
        break;
      case GlobalMode.perform:
        _midiDevice.send(ButtonControls.buttonOn(ButtonCode.perform, 1));
        break;
    }
    _transportControls.update(_midiDevice);
  }

  void shutdown() {
    print("ml 2 shutting down");
    _midiDevice.disconnect();
    print("midi device disconnected");
  }
}

const padDimRatio = 3;
const divisor = (2 * padDimRatio);
PadColor fromSVColor(SVColor c) => fire.PadColor(c.r ~/ divisor, c.g ~/ divisor, c.b ~/ divisor);
