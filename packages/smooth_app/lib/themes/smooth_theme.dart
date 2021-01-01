import 'package:flutter/material.dart';

///
/// dark-theme Color guide
///
/// The material standart dark-theme color is #121212 which is 18, 18, 18, in RGB
/// To counter elevation from certain UI elements the alpha overlay of the element gets changed.
///
/// Standart elevation from objects : https://material.io/design/environment/elevation.html#default-elevations
/// The table shows which elevation belongs to which alpha part: https://material.io/design/color/dark-theme.html#properties
///

class SmoothThemes {
  static ThemeData getSmoothThemeData(bool isDarkTheme, BuildContext context) {
    Color basicDark = const Color.fromRGBO(12, 12, 12, 100);
    return ThemeData(
      //
      //
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      //
      // Icons, SVG images
      accentColor: isDarkTheme ? Colors.white : Colors.black,
      //
      // Scaffold,
      scaffoldBackgroundColor: isDarkTheme ? basicDark : Colors.white,
      //
      // NavigationBar
      bottomAppBarColor: isDarkTheme ? basicDark.withAlpha(12) : Colors.white24,
      //
      // smooth_simple_button
      buttonColor: isDarkTheme ? Colors.white : Colors.black,
      //
      // smooth_listTiles
      cardColor:
          isDarkTheme ? Colors.white.withAlpha(5) : basicDark.withAlpha(10),
      //
      //
      dialogBackgroundColor:
          isDarkTheme ? basicDark.withAlpha(16) : Colors.white,
      //
      //
      //
      //
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline2: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline3: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        headline4: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        bodyText1: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        bodyText2: TextStyle(
          color: isDarkTheme ? Color.fromRGBO(12, g, b, opacity) : Colors.black,
        ),
        subtitle1: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w200,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        subtitle2: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
