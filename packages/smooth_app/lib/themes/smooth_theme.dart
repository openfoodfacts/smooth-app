
import 'package:flutter/material.dart';

class SmoothThemes {

  static ThemeData getSmoothThemeData() {
    return ThemeData(
      primaryColorDark: Colors.black,
      accentColor: Colors.black,
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
        subtitle1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w200, color: Colors.white),
      ),
    );
  }

}