import 'dart:math';

extension StringExt on String {
  String truncate(int max) => substring(0, min(length, max));
}

extension IntExt on int {
  int decrement([int interval = 1]) => max(0, this - 1);
  int increment(int limit, [int interval = 1]) => min(limit, this + 1);
}
