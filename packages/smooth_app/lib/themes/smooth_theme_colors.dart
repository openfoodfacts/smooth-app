import 'package:flutter/material.dart';

class SmoothColorsThemeExtension
    extends ThemeExtension<SmoothColorsThemeExtension> {
  SmoothColorsThemeExtension({
    required this.primaryUltraBlack,
    required this.primaryBlack,
    required this.primaryDark,
    required this.primarySemiDark,
    required this.primaryTone,
    required this.primaryNormal,
    required this.primaryAccent,
    required this.primaryMedium,
    required this.primaryLight,
    required this.secondaryNormal,
    required this.secondaryVibrant,
    required this.secondaryLight,
    required this.error,
    required this.errorGradient,
    required this.successBackground,
    required this.warning,
    required this.warningGradient,
    required this.warningBackground,
    required this.success,
    required this.successGradient,
    required this.errorBackground,
    required this.greyDark,
    required this.greyNormal,
    required this.greyMedium,
    required this.greyLight,
    required this.cellOdd,
    required this.cellEven,
    required this.greyUltraLight,
    required this.greySemiLight,
    required this.greyFair,
    required this.greyUltraDark,
    required this.scoreLightGreen,
    required this.scoreDarkYellow,
    required this.scoreDarkOrange,
    required this.scoreRedBackground,
    required this.scoreOrangeBackground,
    required this.scoreYellowBackground,
    required this.scoreLightGreenBackground,
    required this.scoreDarkGreenBackground,
  });

  SmoothColorsThemeExtension.defaultValues(bool lightTheme)
    : primaryUltraBlack = const Color(0xFF201A17),
      primaryBlack = const Color(0xFF341100),
      primaryDark = const Color(0xFF483527),
      primarySemiDark = const Color(0xFF52443D),
      primaryTone = const Color(0xFF81756C),
      primaryAccent = const Color(0xFF875737),
      primaryNormal = const Color(0xFFA08D84),
      primaryMedium = const Color(0xFFEDE0DB),
      primaryLight = const Color(0xFFF6F3F0),
      secondaryNormal = const Color(0xFFF2994A),
      secondaryVibrant = const Color(0xFFFB8229),
      secondaryLight = const Color(0xFFEE8858),
      success = const Color(0xFF219653),
      successGradient = const Color(0xFF499459),
      successBackground = const Color(0xFFDEEDDB),
      warning = const Color(0xFFFB8229),
      warningGradient = const Color(0xFFF2994A),
      warningBackground = const Color(0xFFF2E2D6),
      error = const Color(0xFFEB5757),
      errorGradient = const Color(0xFFEB5757),
      errorBackground = const Color(0xFFF6E4E4),
      greyDark = const Color(0xFF666666),
      greyNormal = const Color(0xFF6C6C6C),
      greyMedium = const Color(0xFF8F8F8F),
      greyLight = const Color(0xFFE0E0E0),
      cellOdd = lightTheme ? const Color(0xFFFAF8F6) : const Color(0xFF2D251E),
      cellEven = lightTheme ? const Color(0xFFFFFFFF) : const Color(0xFF201A17),
      greyUltraLight = const Color(0xFFF2F2F2),
      greySemiLight = const Color(0xFFBFBFBF),
      greyFair = const Color(0xFF888888),
      greyUltraDark = const Color(0xFF4F4F4F),
      scoreLightGreen = const Color(0xFF60AC0E),
      scoreDarkYellow = const Color(0xFFC88F01),
      scoreDarkOrange = const Color(0xFFE07312),
      scoreRedBackground = const Color(0xFFFFCCCC),
      scoreOrangeBackground = const Color(0xFFFFE6CC),
      scoreYellowBackground = const Color(0xFFFFFFCC),
      scoreLightGreenBackground = const Color(0xFFE6FFCC),
      scoreDarkGreenBackground = const Color(0xFFCCFFCC);

  // Ristreto
  final Color primaryUltraBlack;

  // Chocolate
  final Color primaryBlack;

  // Cortado
  final Color primaryDark;

  // Mocha
  final Color primarySemiDark;

  // Darker Macchiato (from old palette)
  final Color primaryTone;

  final Color primaryAccent;

  // Macchiato
  final Color primaryNormal;

  // Cappuccino
  final Color primaryMedium;

  // Latte
  final Color primaryLight;
  final Color secondaryNormal;
  final Color secondaryVibrant;
  final Color secondaryLight;

  /// When used alone
  final Color error;
  final Color errorBackground;
  final Color warning;
  final Color warningBackground;
  final Color success;
  final Color successBackground;

  /// When used together
  final Color errorGradient;
  final Color warningGradient;
  final Color successGradient;

  final Color greyDark;
  final Color greyNormal;
  final Color greyMedium;
  final Color greyLight;

  final Color cellOdd;
  final Color cellEven;

  /// Unknown score cards, text of average cells in panel tables, packaging
  /// editor cards
  final Color greyUltraLight;

  /// Loading product cards (light), onboarding bottom bar, packaging editor
  /// cards
  final Color greySemiLight;

  /// Background of unknown attribute icons
  final Color greyFair;

  /// Unknown score text, loading product cards (dark), packaging editor cards
  final Color greyUltraDark;

  // Reserved for scores, do not reuse elsewhere.

  /// Text of good score cards, background of good attribute icons
  final Color scoreLightGreen;

  /// Text of neutral score cards
  final Color scoreDarkYellow;

  /// Text of neutral cells in panel tables
  final Color scoreDarkOrange;

  /// Score card backgrounds, from very bad to very good
  final Color scoreRedBackground;
  final Color scoreOrangeBackground;
  final Color scoreYellowBackground;
  final Color scoreLightGreenBackground;
  final Color scoreDarkGreenBackground;

  @override
  ThemeExtension<SmoothColorsThemeExtension> copyWith({
    Color? primaryUltraBlack,
    Color? primaryBlack,
    Color? primaryDark,
    Color? primarySemiDark,
    Color? primaryTone,
    Color? primaryNormal,
    Color? primaryAccent,
    Color? primaryMedium,
    Color? primaryLight,
    Color? secondaryNormal,
    Color? secondaryLight,
    Color? secondaryVibrant,
    Color? error,
    Color? errorGradient,
    Color? errorBackground,
    Color? warning,
    Color? warningGradient,
    Color? warningBackground,
    Color? success,
    Color? successGradient,
    Color? successBackground,
    Color? greyDark,
    Color? greyNormal,
    Color? greyMedium,
    Color? greyLight,
    Color? cellOdd,
    Color? cellEven,
    Color? greyUltraLight,
    Color? greySemiLight,
    Color? greyFair,
    Color? greyUltraDark,
    Color? scoreLightGreen,
    Color? scoreDarkYellow,
    Color? scoreDarkOrange,
    Color? scoreRedBackground,
    Color? scoreOrangeBackground,
    Color? scoreYellowBackground,
    Color? scoreLightGreenBackground,
    Color? scoreDarkGreenBackground,
  }) {
    return SmoothColorsThemeExtension(
      primaryUltraBlack: primaryUltraBlack ?? this.primaryUltraBlack,
      primaryBlack: primaryBlack ?? this.primaryBlack,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySemiDark: primarySemiDark ?? this.primarySemiDark,
      primaryTone: primaryTone ?? this.primaryTone,
      primaryNormal: primaryNormal ?? this.primaryNormal,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      primaryLight: primaryLight ?? this.primaryLight,
      secondaryNormal: secondaryNormal ?? this.secondaryNormal,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryVibrant: secondaryVibrant ?? this.secondaryVibrant,
      error: error ?? this.error,
      errorGradient: errorGradient ?? this.errorGradient,
      errorBackground: errorBackground ?? this.errorBackground,
      warning: warning ?? this.warning,
      warningGradient: warningGradient ?? this.warningGradient,
      warningBackground: warningBackground ?? this.warningBackground,
      success: success ?? this.success,
      successGradient: successGradient ?? this.successGradient,
      successBackground: successBackground ?? this.successBackground,
      greyDark: greyDark ?? this.greyDark,
      greyNormal: greyDark ?? this.greyDark,
      greyMedium: greyMedium ?? this.greyMedium,
      greyLight: greyLight ?? this.greyLight,
      cellOdd: cellOdd ?? this.cellOdd,
      cellEven: cellEven ?? this.cellEven,
      greyUltraLight: greyUltraLight ?? this.greyUltraLight,
      greySemiLight: greySemiLight ?? this.greySemiLight,
      greyFair: greyFair ?? this.greyFair,
      greyUltraDark: greyUltraDark ?? this.greyUltraDark,
      scoreLightGreen: scoreLightGreen ?? this.scoreLightGreen,
      scoreDarkYellow: scoreDarkYellow ?? this.scoreDarkYellow,
      scoreDarkOrange: scoreDarkOrange ?? this.scoreDarkOrange,
      scoreRedBackground: scoreRedBackground ?? this.scoreRedBackground,
      scoreOrangeBackground:
          scoreOrangeBackground ?? this.scoreOrangeBackground,
      scoreYellowBackground:
          scoreYellowBackground ?? this.scoreYellowBackground,
      scoreLightGreenBackground:
          scoreLightGreenBackground ?? this.scoreLightGreenBackground,
      scoreDarkGreenBackground:
          scoreDarkGreenBackground ?? this.scoreDarkGreenBackground,
    );
  }

  @override
  ThemeExtension<SmoothColorsThemeExtension> lerp(
    covariant ThemeExtension<SmoothColorsThemeExtension>? other,
    double t,
  ) {
    if (other is! SmoothColorsThemeExtension) {
      return this;
    }

    return SmoothColorsThemeExtension(
      primaryUltraBlack: Color.lerp(
        primaryUltraBlack,
        other.primaryUltraBlack,
        t,
      )!,
      primaryBlack: Color.lerp(primaryBlack, other.primaryBlack, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySemiDark: Color.lerp(primarySemiDark, other.primarySemiDark, t)!,
      primaryTone: Color.lerp(primaryTone, other.primaryTone, t)!,
      primaryNormal: Color.lerp(primaryNormal, other.primaryNormal, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      primaryMedium: Color.lerp(primaryMedium, other.primaryMedium, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondaryNormal: Color.lerp(secondaryNormal, other.secondaryNormal, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryVibrant: Color.lerp(
        secondaryVibrant,
        other.secondaryVibrant,
        t,
      )!,

      error: Color.lerp(error, other.error, t)!,
      errorGradient: Color.lerp(errorGradient, other.errorGradient, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningGradient: Color.lerp(warningGradient, other.warningGradient, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successGradient: Color.lerp(successGradient, other.successGradient, t)!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      greyDark: Color.lerp(greyDark, other.greyDark, t)!,
      greyNormal: Color.lerp(greyNormal, other.greyNormal, t)!,
      greyMedium: Color.lerp(greyMedium, other.greyMedium, t)!,
      greyLight: Color.lerp(greyLight, other.greyLight, t)!,
      cellOdd: Color.lerp(cellOdd, other.cellOdd, t)!,
      cellEven: Color.lerp(cellEven, other.cellEven, t)!,
      greyUltraLight: Color.lerp(greyUltraLight, other.greyUltraLight, t)!,
      greySemiLight: Color.lerp(greySemiLight, other.greySemiLight, t)!,
      greyFair: Color.lerp(greyFair, other.greyFair, t)!,
      greyUltraDark: Color.lerp(greyUltraDark, other.greyUltraDark, t)!,
      scoreLightGreen: Color.lerp(scoreLightGreen, other.scoreLightGreen, t)!,
      scoreDarkYellow: Color.lerp(scoreDarkYellow, other.scoreDarkYellow, t)!,
      scoreDarkOrange: Color.lerp(scoreDarkOrange, other.scoreDarkOrange, t)!,
      scoreRedBackground: Color.lerp(
        scoreRedBackground,
        other.scoreRedBackground,
        t,
      )!,
      scoreOrangeBackground: Color.lerp(
        scoreOrangeBackground,
        other.scoreOrangeBackground,
        t,
      )!,
      scoreYellowBackground: Color.lerp(
        scoreYellowBackground,
        other.scoreYellowBackground,
        t,
      )!,
      scoreLightGreenBackground: Color.lerp(
        scoreLightGreenBackground,
        other.scoreLightGreenBackground,
        t,
      )!,
      scoreDarkGreenBackground: Color.lerp(
        scoreDarkGreenBackground,
        other.scoreDarkGreenBackground,
        t,
      )!,
    );
  }
}

extension SmoothThemeExtension on BuildContext {
  T extension<T>() {
    return Theme.of(this).extension<T>()!;
  }
}
