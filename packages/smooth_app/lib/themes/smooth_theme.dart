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

  /// The singleton for the theme.
  static SmoothTheme get instance => _instance ??= const SmoothTheme();
  static SmoothTheme? _instance;

  /// Setter that allows tests to override the singleton instance.
  @visibleForTesting
  static set instance(SmoothTheme testInstance) => _instance = testInstance;

  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;

  /// Theme color tags
  static const String COLOR_TAG_BLUE = 'blue';
  static const String COLOR_TAG_GREEN = 'green';
  static const String COLOR_TAG_BROWN = 'brown';

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
    return MATERIAL_COLORS[themeProvider.colorTag] ??
        MATERIAL_COLORS[COLOR_TAG_BLUE]!;
  }

  static ThemeData getThemeData(
    final Brightness brightness,
    final String colorTag,
  ) {
    ColorScheme myColorScheme;
    if (brightness == Brightness.dark) {
      myColorScheme = const ColorScheme.dark();
    } else {
      final MaterialColor materialColor =
          MATERIAL_COLORS[colorTag] ?? MATERIAL_COLORS[COLOR_TAG_BLUE]!;
      myColorScheme = ColorScheme.light(
        primary: materialColor[600]!,
        primaryContainer: materialColor[900],
      );
    }

    return ThemeData(
      colorScheme: myColorScheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: myColorScheme.onSurface,
        unselectedItemColor: myColorScheme.onSurface,
      ),
      textTheme: _TEXT_THEME,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: myColorScheme.secondary,
        foregroundColor: myColorScheme.onSecondary,
      ),
      appBarTheme: AppBarTheme(
        color: brightness == Brightness.dark ? null : myColorScheme.primary,
      ),
      toggleableActiveColor: myColorScheme.primary,
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
    ),
    subtitle2: TextStyle(
      fontSize: 12.0,
    ),
  );
}
