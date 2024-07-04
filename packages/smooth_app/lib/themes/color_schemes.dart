import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/collections_helper.dart';

const Color seed = Color(0xFF99460D);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromRGBO(133, 116, 108, 1.0),
  inversePrimary: Color(0xFF341100),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFEDE0DB),
  onSecondary: Color(0xFF000000),
  error: Color(0xFFEB5757),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFFFFFF),
  onBackground: Color(0xFF000000),
  surface: Color(0xFF85746C),
  onSurface: Color(0xFFFFFFFF),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF000000),
  secondary: Color(0xFFA08D84),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFEB5757),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFF201A17),
  onBackground: Color(0xFFFFFFFF),
  surface: Color(0xFFEDE0DB),
  onSurface: Color(0xFF000000),
);

const ColorScheme trueDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: COLOR_DEFAULT,
  inversePrimary: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF000000),
  secondary: COLOR_DEFAULT,
  onSecondary: Color(0xFFE1E1E1),
  error: Color(0xFFEA2B2B),
  onError: Color(0xFFE1E1E1),
  background: Color(0xFF000000),
  onBackground: Color(0xFFE1E1E1),
  surface: Color(0xFF000000),
  onSurface: Color(0xFFE1E1E1),
);

const String CONTRAST_LOW = 'Low';
const String CONTRAST_MEDIUM = 'Medium';
const String CONTRAST_HIGH = 'High';

// All of the contrast Level passes WCAG 2.1 Results for text Readability.
const Color LOW_CONTRAST_TEXT_COLOR = Color(0xff969696);
const Color MEDIUM_CONTRAST_TEXT_COLOR = Color(0xffcacaca);
const Color HIGH_CONTRAST_TEXT_COLOR = Color(0xffffffff);

const Color Test = Colors.white10;

const String COLOR_DEFAULT_NAME = 'Default';
const Color COLOR_DEFAULT = Color(0xff85746c);
const Color COLOR_BLUE = Colors.blue;
const Color COLOR_CYAN = Color(0xff0097a7);
const Color COLOR_GREEN = Color(0xff009b52);
const Color COLOR_MAGENTA = Color(0xffff00ff);
const Color COLOR_ORANGE = Colors.deepOrange;
const Color COLOR_PINK = Colors.pink;
const Color COLOR_RED = Color(0xffff0000);
const Color COLOR_RUST = Color(0xffb7410e);
const Color COLOR_TEAL = Colors.teal;

const Map<String, Color> colorNamesValue = <String, Color>{
  'Default': COLOR_DEFAULT,
  'Blue': COLOR_BLUE,
  'Cyan': COLOR_CYAN,
  'Green': COLOR_GREEN,
  'Magenta': COLOR_MAGENTA,
  'Orange': COLOR_ORANGE,
  'Pink': COLOR_PINK,
  'Red': COLOR_RED,
  'Rust': COLOR_RUST,
  'Teal': COLOR_TEAL,
};

/// Get Color from Color Name using colorNamesValue
Color getColorValue(String colorName) {
  if (colorNamesValue.containsKey(colorName)) {
    return colorNamesValue.getValueByKeyStartWith(colorName)!;
  }
  return COLOR_DEFAULT;
}

Color getTextContrastLevel(String contrastLevel) {
  switch (contrastLevel) {
    case CONTRAST_LOW:
      return LOW_CONTRAST_TEXT_COLOR;

    case CONTRAST_MEDIUM:
      return MEDIUM_CONTRAST_TEXT_COLOR;

    case CONTRAST_HIGH:
      return HIGH_CONTRAST_TEXT_COLOR;

    default:
      return HIGH_CONTRAST_TEXT_COLOR;
  }
}
