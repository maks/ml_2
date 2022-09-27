import 'package:bonsai/bonsai.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:riverpod/riverpod.dart';

import 'modes/oled/screen.dart';

final sunvoxProvider = FutureProvider<LibSunvox>((ref) async {
  // Log.d("sunvoxProvider", "cwd: ${Directory.current}");
  final sunvox = LibSunvox(0, "./sunvox.so");
  final v = sunvox.versionString();
  Log.d("sunvoxProvider", 'sunvox lib version: $v');

  const filename = "song01.sunvox";
  // const filename = "default1.sunvox";
  await sunvox.load(filename);
  // or as data using Dart's file ops
  // final data = File(filename).readAsBytesSync();
  sunvox.volume = 256;

  Log.d("sunvoxProvider", "project name: ${sunvox.projectName}");
  Log.d("sunvoxProvider", "modules: ${sunvox.moduleSlotsCount}");
  return sunvox;
});

final screenProvider = Provider(((ref) => Screen()));


