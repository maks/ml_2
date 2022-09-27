import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:midi/midi.dart';

enum TransportState { idle, playing, paused, stopped, recording }

class TransportControls {
  
  TransportState _transportState = TransportState.idle;

  TransportState get state => _transportState;

  TransportControls() {
    idle();
  }

  void idle() => _transportState = TransportState.idle;

  void play() => _transportState = TransportState.playing;

  void pause() => _transportState = TransportState.paused;

  void stop() => _transportState = TransportState.stopped;

  void record() => _transportState = TransportState.recording;

  void update(final AlsaMidiDevice midiDevice) {
    _allOff(midiDevice);
    switch (_transportState) {
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
