import 'dart:math';

class Volume {
  int _value = 0;

  Volume(this._value);

  int get value => _value;

  void inc(int amount) => _value = min(_value + amount, 255);
  void dec(int amount) => _value = max(_value - amount, 0);
}
