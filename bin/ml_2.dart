import 'dart:io';

import 'package:ml_2/ml_2.dart';

void main(List<String> arguments) async {
  print('test run...');
  //ml_2.testRun();

  final ml2 = ML2();
  await ml2.sunvoxInit();
  await ml2.fireInit();

  // typically ctrl-c in shell will generate a sigint
  ProcessSignal.sigint.watch().listen((signal) {
    print('sigint disconnecting');
    ml2.shutdown();
    exit(0);
  });
}
