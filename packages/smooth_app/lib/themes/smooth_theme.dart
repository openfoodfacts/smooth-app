import 'package:flutter/material.dart';
import 'package:smooth_app/themes/color_schemes.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothTheme {
  const SmoothTheme._();

  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;

  static ThemeData getThemeData(
    final Brightness brightness,
    final ThemeProvider themeProvider,
  ) {
    late final ColorScheme myColorScheme;

    if (brightness == Brightness.light) {
      myColorScheme = lightColorScheme;
    } else {
      myColorScheme = darkColorScheme;
    }

    return ThemeData(
      fontFamily: 'PlusJakartaSans',
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: myColorScheme.onSurface,
        unselectedItemColor: myColorScheme.onSurface,
      ),
      textTheme: brightness == Brightness.dark
          ? _TEXT_THEME.copyWith(
              headline2: _TEXT_THEME.headline2?.copyWith(color: Colors.white),
              headline4: _TEXT_THEME.headline4?.copyWith(color: Colors.white),
              bodyText2: _TEXT_THEME.bodyText2?.copyWith(color: Colors.white),
            )
          : _TEXT_THEME,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: myColorScheme.secondary,
        foregroundColor: myColorScheme.onSecondary,
      ),
      appBarTheme: AppBarTheme(
        color: brightness == Brightness.dark ? null : myColorScheme.primary,
      ),
      toggleableActiveColor: myColorScheme.primary,
      dividerColor: const Color(0xFFdfdfdf),
    );
  }

  static const TextTheme _TEXT_THEME = TextTheme(
      headline1: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline3: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      headline4: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        letterSpacing: 0.5,
      ),
      subtitle1: TextStyle(
        fontSize: 14.0,
      ),
      subtitle2: TextStyle(
        fontSize: 12.0,
      ));

  static MaterialColor getMaterialColorFromColor(Color color) {
    final Map<int, Color> colorShades = <int, Color>{
      50: getShade(color, value: 0.5),
      100: getShade(color, value: 0.4),
      200: getShade(color, value: 0.3),
      300: getShade(color, value: 0.2),
      400: getShade(color, value: 0.1),
      500: color,
      600: getShade(color, value: 0.1, darker: true),
      700: getShade(color, value: 0.15, darker: true),
      800: getShade(color, value: 0.2, darker: true),
      900: getShade(color, value: 0.25, darker: true),
    };
    return MaterialColor(color.value, colorShades);
  }

  //From: https://stackoverflow.com/a/58604669/13313941
  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1);

    final HSLColor hsl = HSLColor.fromColor(color);
    final HSLColor hslDark = hsl.withLightness(
        (darker ? (hsl.lightness - value) : (hsl.lightness + value))
            .clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
