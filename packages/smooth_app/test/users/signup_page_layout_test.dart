import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/goldens.dart';
import '../tests_utils/mocks.dart';

void main() {
  group('LoginPage looks as expected', () {
    for (final bool themeDark in <bool>[true, false]) {
      final String theme = themeDark ? 'Dark' : 'Light';

      testWidgets(theme, (WidgetTester tester) async {
        late UserPreferences userPreferences;
        late ProductPreferences productPreferences;
        late ThemeProvider themeProvider;

        SharedPreferences.setMockInitialValues(
          mockSharedPreferences(),
        );

        userPreferences = await UserPreferences.getUserPreferences();
        userPreferences.setTheme(theme);

        productPreferences = ProductPreferences(ProductPreferencesSelection(
          setImportance: userPreferences.setImportance,
          getImportance: userPreferences.getImportance,
          notify: () => productPreferences.notifyListeners(),
        ));

        await productPreferences.init(PlatformAssetBundle());
        await userPreferences.init(productPreferences);
        themeProvider = ThemeProvider(userPreferences);
        await tester.pumpWidget(
          MockSmoothApp(
            userPreferences,
            UserManagementProvider(),
            productPreferences,
            themeProvider,
            const SignUpPage(),
          ),
        );
        await tester.pump();

        await expectGoldenMatches(
          find.byType(SignUpPage),
          'signup_page-${theme.toLowerCase()}.png',
        );
        expect(tester, meetsGuideline(textContrastGuideline));
        expect(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(tester, meetsGuideline(iOSTapTargetGuideline));
        expect(tester, meetsGuideline(androidTapTargetGuideline));
      });
    }
  });
}
