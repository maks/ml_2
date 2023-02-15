import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:midi/midi.dart';
import 'package:riverpod/riverpod.dart';

enum TransportState { idle, playing, paused, stopped, recording }

class TransportControls extends StateNotifier<TransportState> {
  TransportControls() : super(TransportState.idle);

  void idle() => state = TransportState.idle;

  void play() => state = TransportState.playing;

  void pause() => state = TransportState.paused;

  void stop() => state = TransportState.stopped;

  void record() => state = TransportState.recording;

  bool get isPlaying => state == TransportState.playing;

  bool get isPaused => state == TransportState.paused; 

  bool get isStopped => state == TransportState.stopped; 

  void update(final AlsaMidiDevice midiDevice) {
    _allOff(midiDevice);
    switch (state) {
      case TransportState.idle:
        midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.color1.index));
        break;
      case TransportState.playing:
        midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.color3.index));
        break;
      case TransportState.paused:
        midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.color1.index));
        break;
      case TransportState.stopped:
        midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.color2.index));
        break;
      case TransportState.recording:
        midiDevice.send(ButtonControls.buttonOn(ButtonCode.record, ButtonLedColor.color2.index));
        break;
    }
  }

  void _allOff(final AlsaMidiDevice midiDevice) {
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.off.index));
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.off.index));
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.record, ButtonLedColor.off.index));
  }

}
