import 'dart:io';

import 'package:dart_sunvox/dart_sunvox.dart';

void testRun() async {
  print("cwd: ${Directory.current}");
  final sunvox = LibSunvox("./sunvox.so");
  final v = sunvox.versionString();
  print('sunvox lib version: $v');

  const filename = "song01.sunvox";
  await sunvox.load(filename);
  // or as data using Dart's file ops
  // final data = File(filename).readAsBytesSync();

  sunvox.volume = 256;

  sunvox.play();
  print("playing:$filename ...");

  await Future<void>.delayed(Duration(seconds: 5));

  sunvox.stop();

  sunvox.shutDown();
}
