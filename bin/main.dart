import 'dart:io';

import 'package:bonsai/bonsai.dart' as bonsai;
import 'package:ml_2/ml_2.dart';
import 'package:ml_2/providers.dart';
import 'package:riverpod/riverpod.dart';

void main(List<String> arguments) async {
  const debug = true;
  if (debug) {
    bonsai.Log.init(true);
    bonsai.Log.i("Main", "initialised ML-2 logging");
  }  

  final container = ProviderContainer(overrides: [
    projectFileNameProvider.overrideWithValue(arguments[0]),
  ]);

  final ml2 = ML2(container);
  await ml2.init();

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    bonsai.Log.d('main', 'sigint disconnecting');
    ml2.shutdown();
    exit(0);
  });
}
