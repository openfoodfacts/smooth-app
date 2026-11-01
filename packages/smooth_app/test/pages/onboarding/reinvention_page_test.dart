import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/reinvention_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/mocks.dart';

// rive needs a native lib: never completes, so the sun stays loading.
class _NoRiveFile implements FileLoader {
  @override
  Future<File> file() => Completer<File>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Like Android 14+ at 200%: small sizes double, large sizes barely grow.
class _AndroidNonLinearScaler extends TextScaler {
  const _AndroidNonLinearScaler();

  @override
  double scale(double fontSize) =>
      fontSize <= 50 ? fontSize * 2 : fontSize + 50;

  @override
  double get textScaleFactor => 2.0;

  @override
  String toString() => 'Android 14 nonlinear 2x';
}

void main() {
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;

  setUpAll(() async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences userPreferences =
        await UserPreferences.getUserPreferences();
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);

    // Line breaks depend on glyph widths: the default test font is not enough.
    final FontLoader openSans = FontLoader('OpenSans');
    for (final String weight in <String>[
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
    ]) {
      openSans.addFont(rootBundle.load('assets/fonts/OpenSans-$weight.ttf'));
    }
    await openSans.load();
  });

  // A clipped paragraph keeps didExceedMaxLines false: compare needed vs given.
  const Size phone = Size(360, 792);
  const double dpr = 3.0;

  for (final TextScaler scaler in <TextScaler>[
    TextScaler.noScaling,
    const TextScaler.linear(1.3),
    const TextScaler.linear(2.0),
    const _AndroidNonLinearScaler(),
  ]) {
    testWidgets('German welcome text is not cut at $scaler', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = phone * dpr;
      tester.view.devicePixelRatio = dpr;
      tester.view.viewPadding = const FakeViewPadding(
        top: 24 * dpr,
        bottom: 48 * dpr,
      );
      tester.view.padding = tester.view.viewPadding;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        Provider<FileLoader>.value(
          value: _NoRiveFile(),
          child: MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: SmoothTheme.getThemeData(
              Brightness.light,
              themeProvider,
              () => colorProvider,
              () => textContrastProvider,
            ),
            builder: (BuildContext context, Widget? child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scaler),
              child: child!,
            ),
            home: const OnboardingHomePage(),
          ),
        ),
      );
      await tester.pump();

      final Finder texts = find.descendant(
        of: find.byType(Expanded),
        matching: find.byType(RichText),
      );
      expect(texts, findsAtLeastNWidgets(2));
      for (final Element text in texts.evaluate()) {
        final RenderParagraph paragraph = text.renderObject! as RenderParagraph;
        final String label = paragraph.text.toPlainText();
        expect(
          paragraph.getMaxIntrinsicHeight(paragraph.size.width),
          lessThanOrEqualTo(paragraph.size.height + 0.5),
          reason: label,
        );

        final Rect slot = tester
            .getRect(
              find
                  .ancestor(
                    of: find.byWidget(text.widget),
                    matching: find.byType(Expanded),
                  )
                  .first,
            )
            .inflate(0.5);
        final Rect painted = MatrixUtils.transformRect(
          paragraph.getTransformTo(null),
          Offset.zero & paragraph.size,
        );
        expect(slot.contains(painted.topLeft), isTrue, reason: label);
        expect(slot.contains(painted.bottomRight), isTrue, reason: label);

        for (final RegExpMatch word in RegExp(r'\S+').allMatches(label)) {
          final List<TextBox> boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: word.start, extentOffset: word.end),
          );
          expect(
            boxes.map((TextBox box) => box.top).toSet(),
            hasLength(1),
            reason: '"${word[0]}" is split across lines',
          );
        }
      }

      // Bubbles stay in proportion with the sentence (22 vs 26 px).
      double lineHeight(String word) {
        final RenderParagraph paragraph =
            find
                    .descendant(
                      of: find.byType(Expanded),
                      matching: find.byWidgetPredicate(
                        (Widget w) =>
                            w is RichText &&
                            w.text.toPlainText().contains(word),
                      ),
                    )
                    .evaluate()
                    .last
                    .renderObject!
                as RenderParagraph;
        final int start = paragraph.text.toPlainText().indexOf(word);
        final TextBox box = paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: start, extentOffset: start + 1),
            )
            .first;
        return MatrixUtils.transformRect(
          paragraph.getTransformTo(null),
          box.toRect(),
        ).height;
      }

      expect(lineHeight('Sie') / lineHeight('gut'), inInclusiveRange(0.7, 1.0));
    });
  }
}
