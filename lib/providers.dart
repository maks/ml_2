import 'package:bonsai/bonsai.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/transport/transport_controls.dart';
import 'package:riverpod/riverpod.dart';

import 'oled/screen.dart';

final projectFileNameProvider = Provider<String>((ref) => "");

final sunvoxProvider = FutureProvider<LibSunvox>((ref) async {
  // Log.d("sunvoxProvider", "cwd: ${Directory.current}");
  final sunvox = LibSunvox(0, "/usr/lib/sunvox.so");
  final v = sunvox.versionString();
  Log.d("sunvoxProvider", 'sunvox lib version: $v');

  final filename = ref.read(projectFileNameProvider);
  Log.d("sunvoxProvider", "loading project file: $filename");

  await sunvox.load(filename);
  // or as data using Dart's file ops
  // final data = File(filename).readAsBytesSync();
 
  Log.d("sunvoxProvider", "project name: ${sunvox.projectName}");
  Log.d("sunvoxProvider", "modules: ${sunvox.moduleSlotsCount}");
  return sunvox;
});

final screenProvider = Provider(((ref) => OledScreen()));

final transportControlsProvider = StateNotifierProvider<TransportControl, TransportState>(
  ((ref) => TransportControl()),
);
