import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

import '../../tests_utils/mocks.dart';

Future<void> _pumpHighlighter(
  WidgetTester tester, {
  required String text,
  required String filter,
}) async {
  SharedPreferences.setMockInitialValues(mockSharedPreferences());

  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();

  late ProductPreferences productPreferences;
  productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () => productPreferences.notifyListeners(),
    ),
  );
  await productPreferences.init(PlatformAssetBundle());
  await userPreferences.init(productPreferences);

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      Center(
        child: TextHighlighter(text: text, filter: filter),
      ),
    ),
  );
  await tester.pump();
}

String _renderedText(WidgetTester tester) {
  final RichText richText = tester.widget<RichText>(
    find.descendant(
      of: find.byType(TextHighlighter),
      matching: find.byType(RichText),
    ),
  );
  final StringBuffer buffer = StringBuffer();
  richText.text.visitChildren((InlineSpan span) {
    if (span is TextSpan && span.text != null) {
      buffer.write(span.text);
    }
    return true;
  });
  return buffer.toString();
}

bool _hasHighlightedSpan(WidgetTester tester) {
  final RichText richText = tester.widget<RichText>(
    find.descendant(
      of: find.byType(TextHighlighter),
      matching: find.byType(RichText),
    ),
  );
  bool highlighted = false;
  richText.text.visitChildren((InlineSpan span) {
    if (span is TextSpan && span.style?.backgroundColor != null) {
      highlighted = true;
    }
    return true;
  });
  return highlighted;
}

void main() {
  group('TextHighlighter', () {
    // Regression test for https://github.com/openfoodfacts/smooth-app/issues/7714
    // The thorn letter "þ" (and "Þ") normalizes to the two-letter "th", so a
    // match found on the normalized text used to desynchronize from the
    // original text and make String.substring throw a RangeError.
    testWidgets(
      'does not crash and keeps the text when normalization changes its length',
      (WidgetTester tester) async {
        await _pumpHighlighter(tester, text: 'Þiþ', filter: 'ith');

        expect(tester.takeException(), isNull);
        expect(_renderedText(tester), 'Þiþ');
        expect(_hasHighlightedSpan(tester), isTrue);
      },
    );

    testWidgets('highlights a plain ASCII match', (WidgetTester tester) async {
      await _pumpHighlighter(tester, text: 'Hello world', filter: 'world');

      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), 'Hello world');
      expect(_hasHighlightedSpan(tester), isTrue);
    });

    testWidgets('matches case and diacritic insensitively', (
      WidgetTester tester,
    ) async {
      await _pumpHighlighter(tester, text: 'Café Crème', filter: 'creme');

      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), 'Café Crème');
      expect(_hasHighlightedSpan(tester), isTrue);
    });

    testWidgets('keeps the whole text when there is no match', (
      WidgetTester tester,
    ) async {
      await _pumpHighlighter(tester, text: 'Hello world', filter: 'xyz');

      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), 'Hello world');
      expect(_hasHighlightedSpan(tester), isFalse);
    });
  });
}
