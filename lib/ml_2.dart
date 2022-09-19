import 'dart:io';

import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:midi/midi.dart';
import 'package:collection/collection.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart' as fire;

class ML2 {
  late final LibSunvox _sunvox;

  Future<void> sunvoxInit() async {
    print("cwd: ${Directory.current}");
    _sunvox = LibSunvox(0, "./sunvox.so");
    final v = _sunvox.versionString();
    print('sunvox lib version: $v');

    const filename = "song01.sunvox";
    await _sunvox.load(filename);
    // or as data using Dart's file ops
    // final data = File(filename).readAsBytesSync();

    _sunvox.volume = 256;

    print("project name: ${_sunvox.projectName}");
    print("modules: ${_sunvox.moduleCount}");
  }

  void play() => _sunvox.play();

  void stop() => _sunvox.stop();

  Future<void> fireInit() async {
    final midiDevices = AlsaMidiDevice.getDevices();
    if (midiDevices.isEmpty) {
      print('missing akai fire controller');
      exit(1);
    }

    // find first Akai Fire controller
    final midiDev = midiDevices.firstWhereOrNull((dev) => dev.name.contains('FL STUDIO'));

    if (midiDev == null) {
      print('missing Akai Fire device');
      return;
    }
    if (!(await midiDev.connect())) {
      print('failed to connect to Akai Fire device');
      return;
    }

    midiDev.send(fire.allOffMessage);
    print('init: all off');

    // uncomment to light up top left grid button blue
    midiDev.send(fire.colorPad(0, 0, fire.PadColor(10, 10, 70)));

    midiDev.receivedMessages.listen((event) {
      //print('input event: $event');
      _handleInput(FireInputEvent.fromMidi(event.data));
    });
  }

  void _handleInput(FireInputEvent event) {
    //print("event: ${event.runtimeType}");
    if (event is ButtonEvent) {
      //print("button: $event");
      if (event.dir == ButtonDirection.Down) {
        if (event.type == ButtonType.Play) {
          print("PLay!");
          play();
        } else if (event.type == ButtonType.Stop) {
          print("Stop!");
          stop();
        } 
      }
    }
    if (event is PadEvent) {
      if (event.dir == ButtonDirection.Down) {
        final note = 10 + (event.row * 8) + event.column;
        print("note:$note");
        final moduleId = _sunvox.findModuleByName("Kicker");
        const track = 0;
        _sunvox.sendEvent(0, moduleId, note, 127);
      }
    }
  }
}
