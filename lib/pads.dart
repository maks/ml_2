import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:dart_sunvox/dart_sunvox.dart';

const padDimRatio = 3;
const divisor = (2 * padDimRatio);
PadColor fromSVColor(SVColor c) => PadColor(c.r ~/ divisor, c.g ~/ divisor, c.b ~/ divisor);
