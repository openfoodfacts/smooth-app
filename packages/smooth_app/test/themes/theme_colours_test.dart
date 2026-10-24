import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

void main() {
  for (final bool light in <bool>[true, false]) {
    test('score and grey colours keep their values (light: $light)', () {
      final SmoothColorsThemeExtension c =
          SmoothColorsThemeExtension.defaultValues(light);

      expect(
        <Color>[
          c.greyUltraLight,
          c.greySemiLight,
          c.greyFair,
          c.greyUltraDark,
          c.scoreLightGreen,
          c.scoreDarkYellow,
          c.scoreDarkOrange,
          c.scoreRedBackground,
          c.scoreOrangeBackground,
          c.scoreYellowBackground,
          c.scoreLightGreenBackground,
          c.scoreDarkGreenBackground,
          c.error,
          c.success,
          c.secondaryNormal,
          c.primaryBlack,
        ].map((Color color) => color.toARGB32()),
        <int>[
          0xFFF2F2F2,
          0xFFBFBFBF,
          0xFF888888,
          0xFF4F4F4F,
          0xFF60AC0E,
          0xFFC88F01,
          0xFFE07312,
          0xFFFFCCCC,
          0xFFFFE6CC,
          0xFFFFFFCC,
          0xFFE6FFCC,
          0xFFCCFFCC,
          0xFFEB5757,
          0xFF219653,
          0xFFF2994A,
          0xFF341100,
        ],
      );
    });
  }

  const Map<CardEvaluation, (int, int)> expected = <CardEvaluation, (int, int)>{
    CardEvaluation.UNKNOWN: (0xFFF2F2F2, 0xFF4F4F4F),
    CardEvaluation.VERY_BAD: (0xFFFFCCCC, 0xFFEB5757),
    CardEvaluation.BAD: (0xFFFFE6CC, 0xFFF2994A),
    CardEvaluation.NEUTRAL: (0xFFFFFFCC, 0xFFC88F01),
    CardEvaluation.GOOD: (0xFFE6FFCC, 0xFF60AC0E),
    CardEvaluation.VERY_GOOD: (0xFFCCFFCC, 0xFF219653),
  };

  for (final Brightness brightness in Brightness.values) {
    testWidgets('score card paints each grade in its colours ($brightness)', (
      WidgetTester tester,
    ) async {
      final bool light = brightness == Brightness.light;
      final double opacity = light
          ? 1
          : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
      const Map<Grade, CardEvaluation> grades = <Grade, CardEvaluation>{
        Grade.UNKNOWN: CardEvaluation.UNKNOWN,
        Grade.E: CardEvaluation.VERY_BAD,
        Grade.D: CardEvaluation.BAD,
        Grade.C: CardEvaluation.NEUTRAL,
        Grade.B: CardEvaluation.GOOD,
        Grade.A: CardEvaluation.VERY_GOOD,
      };

      for (final MapEntry<Grade, CardEvaluation> m in grades.entries) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              brightness: brightness,
              extensions: <ThemeExtension<dynamic>>[
                SmoothColorsThemeExtension.defaultValues(light),
              ],
            ),
            home: Material(
              child: ScoreCard.titleElement(
                titleElement: TitleElement(title: 'description', grade: m.key),
                isClickable: false,
              ),
            ),
          ),
        );

        final (int, int) colours = expected[m.value]!;
        final BoxDecoration decoration =
            tester.widget<Ink>(find.byType(Ink)).decoration! as BoxDecoration;
        expect(
          decoration.color,
          Color(colours.$1).withValues(alpha: opacity),
          reason: '${m.value} background',
        );
        final Color expectedText = light
            ? Color(colours.$2).withValues(alpha: opacity)
            : Colors.white;
        expect(
          tester.widget<Text>(find.text('description')).style!.color,
          expectedText,
          reason: '${m.value} text',
        );
      }
    });
  }
}
