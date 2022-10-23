import 'package:dart_sunvox/dart_sunvox.dart';
import 'package:bonsai/bonsai.dart';
import '../widgets/widget.dart';

void playNote(WidgetContext context, int note, int velocity) {
  final module = context.currentModule;
  const track = 1;
  final moduleId = module?.id;
  if (moduleId == null) {
    context.screen.drawContent(["No Module", "Selected"]);
    return;
  }
  if (moduleId == 0) {
    context.screen.drawContent(["Output Module", "No Sound!"]);
    return;
  }
  // use hardcode full velocity as Fire's pads not sensitive enough
  context.sunvox.sendNote(track, moduleId, note, 128);
}

void stopNote(WidgetContext context, int note) {
  final module = context.currentModule;
  const track = 1;
  final moduleId = module?.id;
  if (moduleId == null) {
    Log.d("stopNote", "no current module!");
    return;
  }
  context.sunvox.sendNote(track, moduleId, sunvoxNoteOffCommand, 127);
}
