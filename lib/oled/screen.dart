import 'dart:math' as math;

import 'package:bonsai/bonsai.dart';
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
const maxVisibleLines = 7;

/// Access to drawing onto the Fire's OLED
class OledScreen {
  final MonoCanvas _oledCanvas = MonoCanvas(128, 64);

  List<bool> get bitmapData => _oledCanvas.data;

  void drawHeading(String heading) {
    _oledCanvas.setCursor(0, 0);
    _oledCanvas.writeString(defaultFont, 1, heading, true, true, 1);
    _oledCanvas.setCursor(0, lineHeight);
    _oledCanvas.writeString(defaultFont, 1, '=' * heading.length, true, true, 1);
  }

  void drawContent(final List<String> content, {bool large = false, Set<int> invertLines = const {}}) {
    final fontLineHieght = large == true ? lineHeight * 3 : lineHeight;
    for (int line = 0; line < math.min(content.length, maxVisibleLines); line++) {
      String lineText = content[line];
      if (lineText.length > 10) {
        log("too long:$lineText");
        lineText = lineText.substring(0, 10);
      }
      _oledCanvas.setCursor(0, (fontLineHieght * line));
      final color = !invertLines.contains(line);
      _oledCanvas.writeString(defaultFont, large ? 2 : 1, lineText, color, false, 1);
    }
  }

  void refresh() {}

  void clear() {
    _oledCanvas.clear();
  }
}
