import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/goldens.dart';
import '../tests_utils/mocks.dart';

void main() {
  group('UserPreferencesPage looks as expected', () {
    for (final bool themeDark in <bool>[true, false]) {
      final String theme = themeDark ? 'dark' : 'light';

      testWidgets(theme, (WidgetTester tester) async {
        // Override & mock out HTTP Requests
        final HttpOverrides? priorOverrides = HttpOverrides.current;
        HttpOverrides.global = MockHttpOverrides();

        late UserPreferences userPreferences;
        late ProductPreferences productPreferences;
        late ThemeProvider themeProvider;

        SharedPreferences.setMockInitialValues(
          mockSharedPreferences(
            themeDark: themeDark,
          ),
        );

        userPreferences = await UserPreferences.getUserPreferences();
        productPreferences = ProductPreferences(ProductPreferencesSelection(
          setImportance: userPreferences.setImportance,
          getImportance: userPreferences.getImportance,
          notify: () => productPreferences.notifyListeners(),
        ));
        await productPreferences.init(PlatformAssetBundle());
        await userPreferences.init(productPreferences);
        themeProvider = ThemeProvider(userPreferences);

        await tester.pumpWidget(MockSmoothApp(
          userPreferences,
          UserManagementProvider(),
          productPreferences,
          themeProvider,
          const UserPreferencesPage(),
        ));
        await tester.pump();

        await expectGoldenMatches(find.byType(UserPreferencesPage),
            'user_preferences_page-$theme.png');
        expect(tester, meetsGuideline(textContrastGuideline));
        expect(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(tester, meetsGuideline(iOSTapTargetGuideline));
        expect(tester, meetsGuideline(androidTapTargetGuideline));

        // Restore prior overrides
        HttpOverrides.global = priorOverrides;
      });
    }
  });
}
