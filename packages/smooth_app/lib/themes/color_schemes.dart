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
