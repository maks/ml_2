import 'dart:math';

extension StringExt on String {
  String truncate(int max) => substring(0, min(length, max));
}
