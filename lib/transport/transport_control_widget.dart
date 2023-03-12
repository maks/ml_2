import 'package:bonsai/bonsai.dart';
import 'package:ml_2/modifiers.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/providers.dart';
import 'package:ml_2/widgets/widget.dart';

class TransportControlWidget extends Widget {
  final WidgetContext _context;

  TransportControlWidget(this._context);

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      switch (event.type) {
        case ButtonType.Play:
          playPause();
          break;
        case ButtonType.Stop:
          stop();
          break;
        case ButtonType.Record:
          record();
          break;
        default:
          log("unexpected button type: ${event.type}");
          break;  
      }
    }
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    // TODO: implement onDial
  }

  @override
  void onFocus() {
    // TODO: implement onFocus
  }

  @override
  void onPad(PadEvent event, Modifiers mods) {
    // TODO: implement onPad
  }

  @override
  void paint() {
    // TODO: implement paint
  }

  void playPause() {
    log("Play-Pause!");
    final transportControls = _context.container.read(transportControlsProvider.notifier);
    final sunvox = _context.sunvox;

    if (transportControls.isPlaying) {
      sunvox.pause();
      transportControls.pause();
    } else if (transportControls.isPaused) {
      sunvox.resume();
      transportControls.play();
    } else {
      sunvox.playFromStart();
      transportControls.play();
    }
  }

  void stop() {
    log("Stop!");
    final sunvox = _context.sunvox;
    final transportControls = _context.container.read(transportControlsProvider.notifier);
    sunvox.stop();
    if (transportControls.isStopped) {
      transportControls.idle();
    } else {
      transportControls.stop();
    }
  }

  void record() {
    log("Record!");
    final transportControls = _context.container.read(transportControlsProvider.notifier);
    // TODO: _sunvox.record();
    transportControls.record();
  }
}
