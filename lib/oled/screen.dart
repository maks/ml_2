import 'dart:math';

import 'package:monochrome_draw/monochrome_draw.dart';
import 'package:oled_font_57/oled_font_57.dart' as font57;

final defaultFont = Font(
  monospace: font57.monospace,
  width: font57.width,
  height: font57.height,
  fontData: font57.fontData,
  lookup: font57.lookup,
);

const lineHeight = 8;
const maxVisibleItems = 4;

/// Access to drawing onto the Fire's OLED
class Screen {
  final MonoCanvas _oledCanvas = MonoCanvas(128, 64);

  List<bool> get bitmapData => _oledCanvas.data;

  void drawHeading(String heading) {
    _oledCanvas.setCursor(0, 0);
    _oledCanvas.writeString(defaultFont, 1, heading, true, true, 1);
    _oledCanvas.setCursor(0, lineHeight);
    _oledCanvas.writeString(defaultFont, 1, '=' * heading.length, true, true, 1);
  }

  void drawContent(List<String> content, {bool large = false}) {
    final fontLineHieght = large == true ? lineHeight * 3 : lineHeight;
    const offset = lineHeight * 2;
    for (int line = 0; line < min(content.length, maxVisibleItems); line++) {
      String lineText = content[line];
      if (lineText.length > 10) {
        print("too long:$lineText");
        lineText = lineText.substring(0, 10);
      }
      _oledCanvas.setCursor(0, (fontLineHieght * line) + offset);
      _oledCanvas.writeString(defaultFont, large ? 2 : 1, lineText, true, false, 1);
    }
  }

  void refresh() {}

  void clear() {
    _oledCanvas.clear();
  }
}
