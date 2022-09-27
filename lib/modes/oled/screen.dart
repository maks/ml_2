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

  void drawLarge(String text) {}

  void refresh() {}

  void clear() {
    _oledCanvas.clear();
  }
}