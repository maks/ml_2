import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';

const padDimRatio = 3;
const divisor = (2 * padDimRatio);
PadColor fromSVColor(SVColor c) => PadColor(c.r ~/ divisor, c.g ~/ divisor, c.b ~/ divisor);

PadColor dim(PadColor color, int dimBy) {
  final int r = (color.r * dimBy).floor();
  final int g = (color.g * dimBy).floor();
  final int b = (color.b * dimBy).floor();
  return PadColor(r, g, b);
}

int padIndexFrom(int column, int row) => column + (row * 16);
