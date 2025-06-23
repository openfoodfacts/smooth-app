import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/goldens.dart';
import '../tests_utils/local_database_mock.dart';
import '../tests_utils/mocks.dart';

void main() {
  group('UserPreferencesPage looks as expected', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        // Override & mock out HTTP Requests
        final HttpOverrides? priorOverrides = HttpOverrides.current;
        HttpOverrides.global = MockHttpOverrides();

        late UserPreferences userPreferences;
        late ProductPreferences productPreferences;
        late ThemeProvider themeProvider;
        late ColorProvider colorProvider;
        late TextContrastProvider textContrastProvider;

        SharedPreferences.setMockInitialValues(mockSharedPreferences());

        userPreferences = await UserPreferences.getUserPreferences();
        userPreferences.setTheme(theme);

        productPreferences = ProductPreferences(
          ProductPreferencesSelection(
            setImportance: userPreferences.setImportance,
            getImportance: userPreferences.getImportance,
            notify: () => productPreferences.notifyListeners(),
          ),
        );
        await productPreferences.init(PlatformAssetBundle());
        await userPreferences.init(productPreferences);
        themeProvider = ThemeProvider(userPreferences);
        colorProvider = ColorProvider(userPreferences);
        textContrastProvider = TextContrastProvider(userPreferences);

        await tester.pumpWidget(
          MockSmoothApp(
            userPreferences,
            UserManagementProvider(),
            productPreferences,
            themeProvider,
            textContrastProvider,
            colorProvider,
            const UserPreferencesPage(),
            localDatabase: MockLocalDatabase(),
          ),
        );
        await tester.pump();

        // We need to lowercase the theme, as on some platforms
        // the name is always lowercase
        await expectGoldenMatches(
          find.byType(UserPreferencesPage),
          'user_preferences_page-${theme.toLowerCase()}.png',
        );
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
