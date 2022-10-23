import 'package:ml_2/modifiers.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/widget.dart';
import 'dart:math' as math;

class OledWidget implements Widget {
  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    // TODO: implement onButton
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
}

class ListScreenWidget extends OledWidget {
  final int viewportLength;
  final List<ListScreenItem> _items = <ListScreenItem>[];
  int _selectedIndex = 0;
  int _viewportTopOffset = 0;

  ListScreenWidget(this.viewportLength);

  @override
  void onDial(DialEvent event, Modifiers mods) {
    if (event.direction == DialDirection.Left) {
      _prev(mods);
    } else if (event.direction == DialDirection.Right) {
      _next(mods);
    } else if (event.direction == DialDirection.TouchOn) {
      _select(mods);
    }
  }

  void _next(Modifiers mods) {
    _selectedIndex = math.min(_items.length - 1, _selectedIndex + 1);
    _updateOffset();
  }

  void _prev(Modifiers mods) {
    _selectedIndex = math.max(0, _selectedIndex - 1);
    _updateOffset();
  }

  void _select(Modifiers mods) {
    _items[_selectedIndex].selected();
  }

  void _updateOffset() {
    while (_selectedIndex > (_viewportTopOffset + viewportLength - 1)) {
      _viewportTopOffset++;
    }
    while (_selectedIndex < _viewportTopOffset) {
      _viewportTopOffset--;
    }
  }
}

class ListScreenItem {
  final String label;
  final Function(String, Object?) _onSelected;
  final Object? data;

  ListScreenItem(this.label, this._onSelected, this.data);

  void selected() => _onSelected(label, data);
}
