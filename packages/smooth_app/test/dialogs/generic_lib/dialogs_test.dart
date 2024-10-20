import 'package:app_store_shared/app_store_shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/goldens.dart';
import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

void main() {
  GlobalVars.appStore = const MockedAppStore();

  group(
    'Dialogs on Contribute Page looks as expected',
    () {
      for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
        const List<String> dialogTypes = <String>[
          'Improving',
          'Software development',
          'Translate',
          // 'Contributors'
          // Currently can't make real http calls from the test library and since this dialog depends on an api call
          // So omitting this one for now
        ];
        for (final String dialogType in dialogTypes) {
          testWidgets(
            '${dialogType}_Page_${theme}_Theme',
            (WidgetTester tester) async {
              late UserPreferences userPreferences;
              late ProductPreferences productPreferences;
              late ThemeProvider themeProvider;
              late ColorProvider colorProvider;
              late TextContrastProvider textContrastProvider;

              SharedPreferences.setMockInitialValues(
                mockSharedPreferences(),
              );

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
                  const UserPreferencesPage(
                    type: PreferencePageType.CONTRIBUTE,
                  ),
                  localDatabase: MockLocalDatabase(),
                ),
              );
              await tester.pumpAndSettle();
              await tester.tap(find.text(dialogType));
              await tester.pumpAndSettle();
              await expectGoldenMatches(
                find.byType(SmoothAlertDialog),
                'user_preferences_page_dialogs_$dialogType-${theme.toLowerCase()}.png',
              );
              expect(tester, meetsGuideline(textContrastGuideline));
              expect(tester, meetsGuideline(labeledTapTargetGuideline));
              expect(tester, meetsGuideline(iOSTapTargetGuideline));
              expect(tester, meetsGuideline(androidTapTargetGuideline));
            },
          );
        }
      }
    },
  );
}
