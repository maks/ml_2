import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:tonic/tonic.dart';

/// Sequencer Data models
/// This is intended to provide a bit of abstraction away from the raw Sunvox data structure classes
/// coming from Sunvox package
class SqPattern {
  final List<SqTrack> tracks;

  SqPattern(this.tracks);

  factory SqPattern.fromSunvox(SVPattern svPattern) {
    final tracks = List<SqTrack>.generate(svPattern.patternTrackCount, (index) => SqTrack([]));
    for (final line in svPattern.data) {
      int i = 0;
      for (final ev in line.events) {
        tracks[i].steps.add(SqStep.fromSVEvent(ev));
        i++;
      }
    }
    return SqPattern(tracks);
  }

  @override
  String toString() {
    return tracks.join("\n");
  }
}

class SqTrack {
  final List<SqStep> steps;

  SqTrack(this.steps);

  @override
  String toString() {
    return steps.join(" ");
  }
}

class SqStep {
  final int note;
  final int velocity;
  final int module;
  final int controller;
  final int controllerValue;

  String get noteAsString => note < 12 ? "--" : Pitch.fromMidiNumber(note).toString().replaceAll("♯", "#");

  SqStep({
    required this.note,
    required this.velocity,
    required this.module,
    required this.controller,
    required this.controllerValue,
  });

  factory SqStep.fromSVEvent(SVPatternEvent svEvent) => SqStep(
        note: svNoteToMidi(svEvent.note),
        velocity: svEvent.velocity,
        module: svEvent.module,
        controller: svEvent.controller,
        controllerValue: svEvent.controllerValue,
      );

  @override
  String toString() {
    return noteAsString;
  }    
}
