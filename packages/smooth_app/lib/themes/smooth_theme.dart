import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/color_schemes.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothTheme {
  const SmoothTheme._();

  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;

  static ThemeData getThemeData(
    final Brightness brightness,
    final ThemeProvider themeProvider,
  ) {
    final ColorScheme myColorScheme;

    if (brightness == Brightness.light) {
      myColorScheme = lightColorScheme;
    } else {
      myColorScheme = darkColorScheme;
    }

    return ThemeData(
      primaryColor: const Color(0xFF341100),
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: const IconThemeData(size: 24.0),
        showSelectedLabels: true,
        selectedItemColor: brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF341100),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        unselectedIconTheme: const IconThemeData(size: 20.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) =>
                states.contains(MaterialState.disabled)
                    ? Colors.grey
                    : myColorScheme.primary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: myColorScheme.primary,
          foregroundColor: myColorScheme.onPrimary),
      textTheme: brightness == Brightness.dark
          ? _TEXT_THEME.copyWith(
              displayMedium: _TEXT_THEME.displayMedium?.copyWith(color: Colors.white),
              headlineMedium: _TEXT_THEME.headlineMedium?.copyWith(color: Colors.white),
              bodyMedium: _TEXT_THEME.bodyMedium?.copyWith(color: Colors.white),
            )
          : _TEXT_THEME,
      appBarTheme: AppBarTheme(
        color: myColorScheme.background,
        foregroundColor: myColorScheme.onBackground,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: const Color(0xFFdfdfdf),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: myColorScheme.secondary,
      ),
      iconTheme: IconThemeData(
        color: myColorScheme.onBackground,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle:
            _TEXT_THEME.bodyMedium?.copyWith(color: myColorScheme.onBackground),
        actionTextColor: myColorScheme.onBackground,
      ),
      bannerTheme: MaterialBannerThemeData(
        contentTextStyle: TextStyle(color: myColorScheme.onSecondary),
        backgroundColor: myColorScheme.secondary,
      ), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return myColorScheme.primary; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return myColorScheme.primary; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return myColorScheme.primary; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return myColorScheme.primary; }
 return null;
 }),
 ),
    );
  }

  static const TextTheme _TEXT_THEME = TextTheme(
      displayLarge: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: LARGE_SPACE,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14.0,
      ),
      titleSmall: TextStyle(
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
