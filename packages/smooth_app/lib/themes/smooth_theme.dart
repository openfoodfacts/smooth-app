import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Color destination
enum ColorDestination {
  APP_BAR_FOREGROUND,
  APP_BAR_BACKGROUND,
  SURFACE_FOREGROUND,
  SURFACE_BACKGROUND,
  BUTTON_FOREGROUND,
  BUTTON_BACKGROUND,
}

class SmoothTheme {
  @visibleForTesting
  const SmoothTheme();

  /// Theme color tags
  static const String COLOR_TAG_BLUE = 'blue';
  static const String COLOR_TAG_GREEN = 'green';
  static const String COLOR_TAG_BROWN = 'brown';

  /// The singleton for the theme.
  static SmoothTheme get instance => _instance ??= const SmoothTheme();
  static SmoothTheme? _instance;

  /// Setter that allows tests to override the singleton instance.
  @visibleForTesting
  static set instance(SmoothTheme testInstance) => _instance = testInstance;

  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;

  /// Theme material colors
  static const Map<String, MaterialColor> MATERIAL_COLORS =
      <String, MaterialColor>{
    COLOR_TAG_BLUE: Colors.lightBlue,
    COLOR_TAG_GREEN: Colors.green,
    COLOR_TAG_BROWN: Colors.brown,
  };

  static Color? getColor(
    final ColorScheme colorScheme,
    final MaterialColor materialColor,
    final ColorDestination colorDestination,
  ) =>
      instance.getColorImpl(colorScheme, materialColor, colorDestination);

  static MaterialColor getMaterialColor(
    final BuildContext context,
  ) =>
      instance.getMaterialColorImpl(context);

  /// Returns a shade of a [materialColor]
  ///
  /// For instance, if you want to display a red button,
  /// you'll use Colors.red as root color,
  /// the destination will be ColorDestination.BUTTON_BACKGROUND,
  /// and you'll specify the current ColorScheme.
  /// For the moment, the ColorScheme matters only for the light/dark switch.
  @protected
  Color? getColorImpl(
    final ColorScheme colorScheme,
    final MaterialColor materialColor,
    final ColorDestination colorDestination,
  ) {
    if (colorScheme.brightness == Brightness.light) {
      switch (colorDestination) {
        case ColorDestination.APP_BAR_BACKGROUND:
        case ColorDestination.SURFACE_FOREGROUND:
        case ColorDestination.BUTTON_BACKGROUND:
          return materialColor[800]!;
        case ColorDestination.APP_BAR_FOREGROUND:
        case ColorDestination.SURFACE_BACKGROUND:
        case ColorDestination.BUTTON_FOREGROUND:
          return materialColor[100]!;
      }
    }
    switch (colorDestination) {
      case ColorDestination.APP_BAR_BACKGROUND:
        return null;
      case ColorDestination.SURFACE_BACKGROUND:
      case ColorDestination.BUTTON_BACKGROUND:
        return materialColor[900]!.withOpacity(ADDITIONAL_OPACITY_FOR_DARK);
      case ColorDestination.APP_BAR_FOREGROUND:
      case ColorDestination.SURFACE_FOREGROUND:
      case ColorDestination.BUTTON_FOREGROUND:
        return materialColor[100]!;
    }
  }

  @protected
  MaterialColor getMaterialColorImpl(final BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    if (MediaQuery.platformBrightnessOf(context) == Brightness.dark) {
      return Colors.grey;
    }
    return themeProvider.customMaterialColor;
  }

  static ThemeData getThemeData(
    final Brightness brightness,
    final ThemeProvider themeProvider,
  ) {
    ColorScheme myColorScheme = ColorScheme.fromSwatch(
      primarySwatch: themeProvider.customMaterialColor,
      brightness: brightness,
      // The standard values from the ThemeData.dark & ThemeDate.light constructors
      backgroundColor: brightness == Brightness.light
          ? Colors.white
          : const Color(0xff121212),
    );

    if (brightness == Brightness.dark) {
      myColorScheme = myColorScheme.copyWith(
        secondary: myColorScheme.primary,
      );
    }

    // TODO(Marvin): Remove when we have a fixed color
    // Fix for current standart color (LightBlue) text color being black not white on certain areas
    if (themeProvider.color.isSimilarTo(const Color(0xFF03A9F4))) {
      myColorScheme = myColorScheme.copyWith(
        onPrimary: Colors.white,
      );
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

extension _ColorExtension on Color {
  bool isSimilarTo(Color color) {
    return alpha == color.alpha &&
        red == color.red &&
        green == color.green &&
        blue == color.blue;
  }
}
