import 'package:flutter/material.dart';

class SmoothThemes {
  static ThemeData getSmoothThemeData() {
    return ThemeData(
      primaryColorDark: Colors.black,
      accentColor: Colors.black,
      textTheme: TextTheme(
        headline1: TextStyle(
            fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline2: TextStyle(
            fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline3: TextStyle(
            fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline4: TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        subtitle1: TextStyle(
            fontSize: 14.0, fontWeight: FontWeight.w200, color: Colors.white),
      ),
    );
  }
}
