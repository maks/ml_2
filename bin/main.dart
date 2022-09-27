import 'dart:io';

import 'package:bonsai/bonsai.dart';
import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:ml_2/ml_2.dart';
import 'package:ml_2/modes/module_mode.dart';
import 'package:ml_2/modes/note_mode.dart';
import 'package:ml_2/modes/oled/screen.dart';
import 'package:ml_2/modes/perform_mode.dart';
import 'package:ml_2/modes/step_mode.dart';
import 'package:ml_2/providers.dart';
import 'package:riverpod/riverpod.dart';

void main(List<String> arguments) async {
  const debug = true;
  if (debug) {
    Log.init(true);
  }  

  final container = ProviderContainer();

  final LibSunvox sunvox = await container.read(sunvoxProvider.future);
  final Screen screen = container.read(screenProvider);

  final modes = [StepMode(), NoteMode(), ModuleMode(sunvox, screen), PerformMode()];

  final ml2 = ML2(screen, sunvox, modes);
  await ml2.fireInit();

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    Log.d('main', 'sigint disconnecting');
    ml2.shutdown();
    exit(0);
  });
}
