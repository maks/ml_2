import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:midi/midi.dart';
import 'package:riverpod/riverpod.dart';

enum _TransportPlaybackState { idle, playing, paused, stopped, recording }

class TransportState {
  final int line;
  final _TransportPlaybackState _playState;

  TransportState._(this.line, this._playState);

  bool get isPlaying => _playState == _TransportPlaybackState.playing;

  bool get isPaused => _playState == _TransportPlaybackState.paused;

  bool get isStopped => _playState == _TransportPlaybackState.stopped;

  bool get isIdle => _playState == _TransportPlaybackState.idle;

  bool get isRecording => _playState == _TransportPlaybackState.recording;

  factory TransportState.idle() {
    return TransportState._(0, _TransportPlaybackState.idle);
  }

  factory TransportState.playing(int line) {
    return TransportState._(line, _TransportPlaybackState.playing);
  }

  factory TransportState.paused(int line) {
    return TransportState._(line, _TransportPlaybackState.paused);
  }

  factory TransportState.stopped(int line) {
    return TransportState._(line, _TransportPlaybackState.stopped);
  }

  factory TransportState.recording(int line) {
    return TransportState._(line, _TransportPlaybackState.recording);
  }

  TransportState copyWith(int line) => TransportState._(line, _playState);
}


class TransportControls extends StateNotifier<TransportState> {

  TransportControls() : super(TransportState.idle());

  void idle() => state = TransportState.idle();

  void play() => state = TransportState.playing(state.line);

  void pause() => state = TransportState.paused(state.line);

  void stop() => state = TransportState.stopped(state.line);

  void record() => state = TransportState.recording(state.line);

  bool get isPlaying => state.isPlaying;

  bool get isPaused => state.isPaused; 

  bool get isStopped => state.isStopped; 

  void update(final AlsaMidiDevice midiDevice) {
    _allOff(midiDevice);

    if (state.isIdle) {
      midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.color1.index));
    } else if (state.isPaused) {
      midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.color1.index));
    } else if (state.isPlaying) {
      midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.color3.index));
    } else if (state.isStopped) {
      midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.color2.index));
    } else if (state.isRecording) {
      midiDevice.send(ButtonControls.buttonOn(ButtonCode.record, ButtonLedColor.color2.index));
    }
  }

  bool updateLine(int line) {
    if (line != state.line) {
      state = state.copyWith(line);
      return true;
    }
    return false;
  }

  void _allOff(final AlsaMidiDevice midiDevice) {
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.play, ButtonLedColor.off.index));
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.stop, ButtonLedColor.off.index));
    midiDevice.send(ButtonControls.buttonOn(ButtonCode.record, ButtonLedColor.off.index));
  }

}
