import 'package:flutter/material.dart';

const Color seed = Color(0xFF99460D);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromRGBO(133, 116, 108, 1.0),
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
  primary: Colors.teal,
  onPrimary: Color(0xFFE1E1E1),
  secondary: Colors.teal,
  onSecondary: Color(0xFFE1E1E1),
  error: Color(0xFFEA2B2B),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFF000000),
  onBackground: Color(0xFFE1E1E1),
  surface: Color(0xFF000000),
  onSurface: Color(0xFFE1E1E1),
);

const String COLOR_DEFAULT_NAME = 'Teal';
const Color COLOR_DEFAULT = Colors.teal;
const Color COLOR_BLUE = Colors.blue;
const Color COLOR_ROSE_BRIGHT = Color(0xffff007f);
const Color COLOR_RUST = Color(0xffb7410e);
const Color COLOR_ORANGE_BRIGHT = Color(0xffffa500);
const Color COLOR_RED = Colors.red;
const Color COLOR_GREEN = Colors.green;
const Color COLOR_PLUM_LIGHT = Color(0xfff400af);

const Map<String, Color> colorNamesValue = <String, Color>{
  'Blue': COLOR_BLUE,
  'Green': COLOR_GREEN,
  'Orange Bright': COLOR_ORANGE_BRIGHT,
  'Plum Light': COLOR_PLUM_LIGHT,
  'Red': COLOR_RED,
  'Rose Bright': COLOR_ROSE_BRIGHT,
  'Rust': COLOR_RUST,
  'Teal': COLOR_DEFAULT,
};
