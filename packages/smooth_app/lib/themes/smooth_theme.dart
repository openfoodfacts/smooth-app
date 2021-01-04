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
  static ThemeData getSmoothThemeData(bool isDarkTheme, BuildContext context) {
    const Color basicDark = Color(0xFF181818);
    const Color basicDark2 = Color(0xFF434343);
    const Color basicDark3 = Color(0xFF696464);

    const Color navBarBlack = Color(0xB3181818);

    const Color accentDark = Color(0xFF00c896);

    return ThemeData(
      //
      // bottom_sheet
      primaryColor: isDarkTheme ? Colors.red : Colors.white,
      //
      // Icons, SVG images
      accentColor: isDarkTheme ? Colors.white : Colors.black,
      //
      // Scaffold,
      scaffoldBackgroundColor: isDarkTheme ? basicDark : Colors.white,
      //
      // NavigationBar
      bottomAppBarColor: isDarkTheme ? navBarBlack : Colors.white24,
      //
      // smooth_simple_button
      buttonColor: isDarkTheme ? basicDark3 : Colors.black,
      //
      // smooth_listTiles
      cardColor: isDarkTheme ? basicDark2 : Colors.black.withAlpha(10),
      //
      //
      dialogBackgroundColor: isDarkTheme ? basicDark2 : Colors.white,
      //
      //
      accentIconTheme:
          IconThemeData(color: isDarkTheme ? Colors.black : Colors.white),
      //
      //
      appBarTheme: AppBarTheme(
        color: isDarkTheme ? basicDark2 : Colors.white,
      ),
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
          color: isDarkTheme ? basicDark : Colors.black,
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
