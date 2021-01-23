import 'package:flutter/material.dart';

class SmoothTheme {
  static ThemeData getThemeData(final Brightness brightness) {
    final ColorScheme myColorScheme =
        brightness == Brightness.dark ? _COLOR_DARK : _COLOR_LIGHT;
    return ThemeData(
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: myColorScheme.onSurface,
        unselectedItemColor: myColorScheme.onSurface,
      ),
      textTheme: _TEXT_THEME,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: myColorScheme.onSurface,
        actionTextColor: myColorScheme.surface,
      ),
    );
  }

  static const ColorScheme _COLOR_LIGHT = ColorScheme.light(
    primary: Colors.white,
    primaryVariant: Colors.white60,
    secondary: Colors.black,
    secondaryVariant: Colors.black,
    onPrimary: Colors.black,
    onSecondary: Colors.white,
  );

  static const ColorScheme _COLOR_DARK = ColorScheme.dark(
    primary: Colors.black,
    primaryVariant: Colors.black,
    secondary: Colors.white,
    secondaryVariant: Colors.white60,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
  );

  static const TextTheme _TEXT_THEME = TextTheme(
    headline1: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    headline3: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    bodyText2: TextStyle(
      fontSize: 14,
      letterSpacing: 0.5,
    ),
    subtitle1: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w200,
    ),
    subtitle2: TextStyle(
      fontSize: 12.0,
    ),
  );
}
