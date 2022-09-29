import 'dart:io';

import 'package:bonsai/bonsai.dart';
import 'package:ml_2/ml_2.dart';
import 'package:riverpod/riverpod.dart';

void main(List<String> arguments) async {
  const debug = true;
  if (debug) {
    Log.init(true);
  }  

  final container = ProviderContainer();

  final ml2 = ML2(container);
  await ml2.init();

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    Log.d('main', 'sigint disconnecting');
    ml2.shutdown();
    exit(0);
  });
}
