import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/color_schemes.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothTheme {
  const SmoothTheme._();

  static const double ADDITIONAL_OPACITY_FOR_DARK = .3;
  static const double SECONDARY_COLOR_SHADE_VALUE = 0.4;

  static ThemeData getThemeData(
    final Brightness brightness,
    final ThemeProvider themeProvider,
    final ColorProvider colorProvider,
    final TextContrastProvider textContrastProvider,
  ) {
    ColorScheme myColorScheme;

    if (brightness == Brightness.light) {
      myColorScheme = lightColorScheme;
    } else {
      if (themeProvider.currentTheme == THEME_AMOLED) {
        myColorScheme = trueDarkColorScheme.copyWith(
          primary: getColorValue(colorProvider.currentColor),
          secondary: getShade(
            getColorValue(colorProvider.currentColor),
            darker: true,
            value: SECONDARY_COLOR_SHADE_VALUE,
          ),
        );
      } else {
        myColorScheme = darkColorScheme;
      }
    }

    final SmoothColorsThemeExtension smoothExtension =
        SmoothColorsThemeExtension.defaultValues();

    return ThemeData(
      fontFamily: 'OpenSans',
      primaryColor: DARK_BROWN_COLOR,
      extensions: <ThemeExtension<dynamic>>[smoothExtension],
      colorScheme: myColorScheme,
      canvasColor: themeProvider.currentTheme == THEME_AMOLED
          ? myColorScheme.surface
          : null,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? null : const Color(0xFF303030),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            brightness == Brightness.light ? null : const Color(0xFF303030),
        selectedIconTheme: const IconThemeData(size: 24.0),
        showSelectedLabels: true,
        selectedItemColor: brightness == Brightness.dark
            ? myColorScheme.primary
            : DARK_BROWN_COLOR,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        unselectedIconTheme: const IconThemeData(size: 20.0),
        elevation: 0.0,
        enableFeedback: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? Colors.grey
                : myColorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? Colors.white
                : myColorScheme.onPrimary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: myColorScheme.primary,
          foregroundColor: myColorScheme.onPrimary),
      textTheme: brightness == Brightness.dark
          ? getTextTheme(themeProvider, textContrastProvider)
          : _TEXT_THEME,
      appBarTheme: AppBarTheme(
        color: myColorScheme.surface,
        foregroundColor: myColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: const Color(0xFFdfdfdf),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: myColorScheme.secondary,
      ),
      iconTheme: IconThemeData(
        color: myColorScheme.onSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: _TEXT_THEME.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: Colors.white,
        backgroundColor: smoothExtension.primaryBlack,
      ),
      bannerTheme: MaterialBannerThemeData(
        contentTextStyle: TextStyle(color: myColorScheme.onSecondary),
        backgroundColor: myColorScheme.secondary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return myColorScheme.primary;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return myColorScheme.primary;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return myColorScheme.primary;
          }
          return null;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return myColorScheme.primary;
          }
          return null;
        }),
      ),
    );
  }

  static TextTheme getTextTheme(
      ThemeProvider themeProvider, TextContrastProvider textContrastProvider) {
    final Color contrastLevel = themeProvider.currentTheme == THEME_AMOLED
        ? getTextContrastLevel(textContrastProvider.currentContrastLevel)
        : Colors.white;

    return _TEXT_THEME.copyWith(
      displayMedium: _TEXT_THEME.displayMedium?.copyWith(color: contrastLevel),
      headlineMedium:
          _TEXT_THEME.headlineMedium?.copyWith(color: contrastLevel),
      bodyMedium: _TEXT_THEME.bodyMedium?.copyWith(color: contrastLevel),
      displaySmall: _TEXT_THEME.bodySmall?.copyWith(color: contrastLevel),
      titleLarge: _TEXT_THEME.titleLarge?.copyWith(color: contrastLevel),
      titleMedium: _TEXT_THEME.titleMedium?.copyWith(color: contrastLevel),
      titleSmall: _TEXT_THEME.titleSmall?.copyWith(color: contrastLevel),
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
    ),
  );

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
