import 'package:ml_2/extensions.dart';
import 'package:ml_2/modifiers.dart';
import 'package:dart_fire_midi/dart_fire_midi.dart';
import 'package:ml_2/widgets/widget.dart';
import 'dart:math' as math;

import '../oled/screen.dart';

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

abstract class ListItemProvider {
  String? itemName(int index);
}

typedef OnItemSelected<T> = void Function(String name, T? data);

class OledListScreenWidget extends OledWidget {
  static const viewPortSize = maxVisibleLines;

  final OledScreen _screen;
  final ListItemProvider _itemProvider;
  final List<ListScreenItem> _items = <ListScreenItem>[];
  final OnItemSelected _onSelected;

  int _selectedIndex = 0;
  int get _viewportTopOffset => (_selectedIndex < viewPortSize ? 0 : _selectedIndex - (_selectedIndex % viewPortSize));

  OledListScreenWidget(this._screen, this._itemProvider, this._onSelected);

  @override
  void onFocus() {
    if (_items.isEmpty) {
      _fillViewport(); 
    } else {
      paint();
    }
  }

  @override
  void onDial(DialEvent event, Modifiers mods) {
    if (event.direction == DialDirection.Left) {
      _prev(mods);
    } else if (event.direction == DialDirection.Right) {
      _next(mods);
    } 
    //TODO for now manually update
    paint();
  }

  @override
  void onButton(ButtonEvent event, Modifiers mods) {
    if (event.direction == ButtonDirection.Down) {
      if (event.type == ButtonType.Select) {
        _onSelected(_items[_selectedIndex].label, null);
        paint();
      }
    }
  }

  @override
  void paint() {
    final lines = _items.skip(_viewportTopOffset).take(viewPortSize).map((e) => e.label.truncate(10)).toList();
    _screen.drawContent(lines, invertLines: {_selectedIndex % viewPortSize});
    print("Paint: ${lines.join(',')} [$_selectedIndex] $_viewportTopOffset [${_items.length}]");
  } 

  // request all available items that are visible in viewport
  void _fillViewport() {
    int i = _items.length;
    final end = i + viewPortSize;
    String? nextItemName = _itemProvider.itemName(i);
    while (nextItemName != null && i <= end) {
      _items.insert(i, ListScreenItem<void>(nextItemName, null));
      nextItemName = _itemProvider.itemName(++i);
    }
    //TODO for now manually call
    paint();
  }

  void _next(Modifiers mods) {
    if (_selectedIndex + viewPortSize > _items.length) {
      _fillViewport();
      // if after filling the viewport there is a item for selectedIndex then increment it
      if (_items.length > _selectedIndex + 1) {
        _selectedIndex++;
      }
    } else {
      _selectedIndex++;
    }    
  }

  void _prev(Modifiers mods) {
    _selectedIndex = math.max(0, _selectedIndex - 1);
  }

}

class ListScreenItem<T> {
  final String label;
  final T? data;

  ListScreenItem(this.label, this.data);
}
