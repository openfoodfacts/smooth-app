import 'package:flutter/material.dart';

class SmoothThemes {
  static ThemeData getSmoothThemeData(
    bool isDarkTheme,
    BuildContext context,
  ) {
    // yellowAccent == null
    const ColorScheme colorLight = ColorScheme(
      primary: Colors.white,
      primaryVariant: Colors.yellowAccent,
      secondary: Color(0xFF696464),
      secondaryVariant: Colors.yellowAccent,
      surface: Colors.white,
      background: Colors.white,
      error: Color(0xFFf00a2c),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    );
    // yellowAccent == null
    const ColorScheme colorDark = ColorScheme(
      primary: Color(0xFF181818),
      primaryVariant: Colors.yellowAccent,
      secondary: Colors.black,
      secondaryVariant: Colors.yellowAccent,
      surface: Color(0xFF181818),
      background: Colors.black,
      error: Color(0xFFf00a2c),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    );

    final ColorScheme myColorScheme = isDarkTheme ? colorDark : colorLight;

    return ThemeData(
      applyElevationOverlayColor: true,
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? const Color(0xB3181818) : Colors.white24,
        selectedIconTheme: IconThemeData(
          color: myColorScheme.onSurface,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.blueGrey,
        ),
      ),
      scaffoldBackgroundColor: myColorScheme.background,
      cardColor: isDarkTheme ? myColorScheme.surface : const Color(0xFFF5F5F5),
      buttonColor: myColorScheme.secondary,
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: myColorScheme.onBackground,
        ),
        headline2: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: myColorScheme.onSurface,
        ),
        headline3: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: myColorScheme.onSurface,
        ),
        headline4: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: myColorScheme.onSurface,
        ),
        bodyText2: TextStyle(
          color: myColorScheme.onSurface,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        subtitle1: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w200,
          color: myColorScheme.onSurface,
        ),
        subtitle2: TextStyle(
          color: myColorScheme.onSurface,
        ),
      ),
    );
  }
}
