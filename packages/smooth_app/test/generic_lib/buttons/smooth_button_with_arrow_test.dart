import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

void main() {
  group('SmoothButtonWithArrow', () {
    testWidgets('wraps text when constrained horizontally without overflowing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              SmoothColorsThemeExtension.defaultValues(true),
            ],
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                // Force a very narrow constraint so the text has to wrap
                width: 100.0,
                child: SmoothButtonWithArrow(
                  text: 'A very very very long text that must wrap',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders without RenderFlex overflow exceptions.
      // The test framework automatically catches overflows as FlutterError during layout/paint.
      expect(find.byType(SmoothButtonWithArrow), findsOneWidget);
    });

    testWidgets('lays out normally when given sufficient width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              SmoothColorsThemeExtension.defaultValues(true),
            ],
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                // Unconstrained or very large width
                width: 1000.0,
                child: SmoothButtonWithArrow(
                  text: 'Short text',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SmoothButtonWithArrow), findsOneWidget);
    });
  });
}
