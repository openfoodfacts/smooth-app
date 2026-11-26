import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/app_localizations_delegates.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_close_button.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/mocks.dart';

class _NoRiveFile implements FileLoader {
  @override
  Future<File> file() => Completer<File>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  group('ScanProductCardNotFound', () {
    testWidgets('does not overflow at constrained heights in either density', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(mockSharedPreferences());
      final UserPreferences userPreferences =
          await UserPreferences.getUserPreferences();
      final ThemeProvider themeProvider = ThemeProvider(userPreferences);
      final ColorProvider colorProvider = ColorProvider(userPreferences);
      final TextContrastProvider textContrastProvider = TextContrastProvider(
        userPreferences,
      );

      final ThemeData themeData = SmoothTheme.getThemeData(
        Brightness.light,
        themeProvider,
        () => colorProvider,
        () => textContrastProvider,
      );

      for (final ScanCardDensity density in <ScanCardDensity>[
        ScanCardDensity.NORMAL,
        ScanCardDensity.DENSE,
      ]) {
        for (final double height in <double>[180.0, 220.0, 260.0]) {
          await tester.pumpWidget(
            Provider<FileLoader>.value(
              value: _NoRiveFile(),
              child: ChangeNotifierProvider<ThemeProvider>.value(
                value: themeProvider,
                child: MaterialApp(
                  localizationsDelegates: appLocalizationsDelegates,
                  theme: themeData,
                  home: Scaffold(
                    body: Provider<ScanCardDensity>.value(
                      value: density,
                      child: SizedBox(
                        height: height,
                        child: ScanProductCardNotFound(barcode: '12345678'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets(
      'dismiss button is clipped from orange graphic and remains tappable in NORMAL and DENSE',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues(mockSharedPreferences());
        final UserPreferences userPreferences =
            await UserPreferences.getUserPreferences();
        final ThemeProvider themeProvider = ThemeProvider(userPreferences);
        final ColorProvider colorProvider = ColorProvider(userPreferences);
        final TextContrastProvider textContrastProvider = TextContrastProvider(
          userPreferences,
        );

        final ThemeData themeData = SmoothTheme.getThemeData(
          Brightness.light,
          themeProvider,
          () => colorProvider,
          () => textContrastProvider,
        );

        for (final ScanCardDensity density in <ScanCardDensity>[
          ScanCardDensity.NORMAL,
          ScanCardDensity.DENSE,
        ]) {
          int removeCount = 0;

          await tester.pumpWidget(
            Provider<FileLoader>.value(
              value: _NoRiveFile(),
              child: ChangeNotifierProvider<ThemeProvider>.value(
                value: themeProvider,
                child: MaterialApp(
                  localizationsDelegates: appLocalizationsDelegates,
                  theme: themeData,
                  home: Scaffold(
                    body: Provider<ScanCardDensity>.value(
                      value: density,
                      child: SizedBox(
                        height: density == ScanCardDensity.DENSE
                            ? 260.0
                            : 450.0,
                        child: ScanProductCardNotFound(
                          barcode: '12345678',
                          onRemoveProduct: (_) => removeCount++,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          final Finder closeButtonFinder = find.byType(SmoothCloseButton);
          final Finder orangeFinder = find.byType(OrangeErrorAnimation);

          expect(closeButtonFinder, findsOneWidget);
          expect(orangeFinder, findsOneWidget);
          expect(
            find.descendant(
              of: orangeFinder,
              matching: find.byType(ClipRect),
            ),
            findsOneWidget,
          );

          final Rect closeRect = tester.getRect(closeButtonFinder);
          final Rect orangeRect = tester.getRect(orangeFinder);
          expect(orangeRect.overlaps(closeRect), isFalse);
          expect(orangeRect.top, greaterThanOrEqualTo(closeRect.bottom));

          await tester.tap(closeButtonFinder);
          await tester.pump();
          expect(removeCount, 1);
        }
      },
    );
  });
}
