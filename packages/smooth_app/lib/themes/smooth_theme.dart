import 'package:flutter/material.dart';

///
/// dark-theme Color guide
///
/// The material standard dark-theme color is #181818 which is also in use here
///
/// Sec black:   #434343
/// Third black: #696464
/// Accent:      #00c896
///
/// Hex colors in dart = Color(0xAABBCCDD)
///
/// BB, CC, DD is the normal hex
///
/// AA is the opacity a tabel of the codes per procent can be found here:
/// https://www.codegrepper.com/code-examples/dart/flutter+hex+opacity
///

class SmoothThemes {
  static ThemeData getSmoothThemeData(
    bool isDarkTheme,
    BuildContext context,
  ) {
    //accentDark = Color(0xFF00c896);

    const ColorScheme colorDark = ColorScheme(
      primary: Colors.black,
      primaryVariant: Colors.indigo,
      secondary: Colors.indigo,
      secondaryVariant: Colors.indigo,
      surface: Color(0xFF434343),
      background: Color(0xFF181818),
      error: Colors.indigo,
      onPrimary: Colors.indigo,
      onSecondary: Colors.indigo,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.indigo,
      brightness: Brightness.dark,
    );

    const ColorScheme colorLight = ColorScheme(
      primary: Colors.white,
      primaryVariant: Colors.indigo,
      secondary: Colors.indigo,
      secondaryVariant: Colors.indigo,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.indigo,
      onPrimary: Colors.indigo,
      onSecondary: Colors.indigo,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.indigo,
      brightness: Brightness.light,
    );

    final ColorScheme myColorScheme = isDarkTheme ? colorDark : colorLight;

    return ThemeData(
      colorScheme: myColorScheme,
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.accent,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: isDarkTheme ? const Color(0xFF696464) : Colors.black,
              // secondary will be the textColor, when the textTheme is set to accent
              secondary: Colors.white,
            ),
      ),
      cardColor: isDarkTheme ? colorDark.surface : const Color(0xFFF5F5F5),
      dialogBackgroundColor: myColorScheme.surface,
      accentIconTheme:
          IconThemeData(color: isDarkTheme ? Colors.black : Colors.white),
      appBarTheme: AppBarTheme(
        color: myColorScheme.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              isDarkTheme ? const Color(0xB3181818) : Colors.white24,
          selectedIconTheme: IconThemeData(
            color: myColorScheme.onSurface,
          ),
          unselectedIconTheme: const IconThemeData(
            color: Colors.blueGrey,
          )),
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
