import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../utils/goldens.dart';
import '../utils/mocks.dart';

void main() {
  group('UserPreferencesPage looks as expected', () {
    for (final String color in <String>['blue', 'brown', 'green']) {
      for (final bool themeDark in <bool>[true, false]) {
        final String theme = themeDark ? 'dark' : 'light';

        testWidgets('$color / $theme', (WidgetTester tester) async {
          // Override & mock out HTTP Requests
          final HttpOverrides? priorOverrides = HttpOverrides.current;
          HttpOverrides.global = MockHttpOverrides();

          late UserPreferences _userPreferences;
          late ProductPreferences _productPreferences;
          late ThemeProvider _themeProvider;

          SharedPreferences.setMockInitialValues(mockSharedPreferences(
            colorTag: color,
            themeDark: themeDark,
          ));

          _userPreferences = await UserPreferences.getUserPreferences();
          _productPreferences = ProductPreferences(ProductPreferencesSelection(
            setImportance: _userPreferences.setImportance,
            getImportance: _userPreferences.getImportance,
            notify: () => _productPreferences.notifyListeners(),
          ));
          await _productPreferences.init(PlatformAssetBundle());
          await _userPreferences.init(_productPreferences);
          _themeProvider = ThemeProvider(_userPreferences);

          await tester.pumpWidget(MockSmoothApp(
            _userPreferences,
            _productPreferences,
            _themeProvider,
            const UserPreferencesPage(),
          ));
          await tester.pump();

          await expectGoldenMatches(find.byType(UserPreferencesPage),
              'user_preferences_page-$color-$theme.png');
          expect(tester, meetsGuideline(textContrastGuideline));
          expect(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester, meetsGuideline(iOSTapTargetGuideline));
          expect(tester, meetsGuideline(androidTapTargetGuideline));

          // Restore prior overrides
          HttpOverrides.global = priorOverrides;
        });
      }
    }
  });
}
