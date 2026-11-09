import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

const String _allergensGroupId = AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS;

Future<UserPreferences> _pumpFoodSearch(
  WidgetTester tester,
  String query,
) async {
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
  await userPreferences.setActiveAttributeGroup('');

  final ThemeProvider themeProvider = ThemeProvider(userPreferences);
  final ColorProvider colorProvider = ColorProvider(userPreferences);
  final TextContrastProvider textContrastProvider = TextContrastProvider(
    userPreferences,
  );

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      themeProvider,
      textContrastProvider,
      colorProvider,
      Builder(
        builder: (BuildContext context) {
          final UserPreferencesFood foodPreferences = UserPreferencesFood(
            productPreferences: productPreferences,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: AppLocalizations.of(context),
            themeData: Theme.of(context),
          );
          return Scaffold(
            body: ListView(
              children: foodPreferences.searchTiles(context, query),
            ),
          );
        },
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pumpAndSettle();

  return userPreferences;
}

void main() {
  testWidgets(
    'searching "Food Preferences" does not expand an attribute group',
    (WidgetTester tester) async {
      final UserPreferences userPreferences = await _pumpFoodSearch(
        tester,
        'Food Preferences',
      );

      expect(find.text('Food Preferences'), findsOneWidget);
      await tester.tap(find.text('Food Preferences'));
      await tester.pumpAndSettle();

      expect(userPreferences.activeAttributeGroup, isEmpty);
    },
  );

  testWidgets('searching "Allergens" expands the Allergens attribute group', (
    WidgetTester tester,
  ) async {
    final UserPreferences userPreferences = await _pumpFoodSearch(
      tester,
      'Allergens',
    );

    expect(find.text('Allergens'), findsOneWidget);
    await tester.tap(find.text('Allergens'));
    await tester.pumpAndSettle();

    expect(userPreferences.activeAttributeGroup, _allergensGroupId);
  });

  testWidgets('searching "Gluten" expands the Allergens attribute group', (
    WidgetTester tester,
  ) async {
    final UserPreferences userPreferences = await _pumpFoodSearch(
      tester,
      'Gluten',
    );

    expect(find.text('Gluten'), findsWidgets);
    await tester.tap(find.text('Gluten'));
    await tester.pumpAndSettle();

    expect(userPreferences.activeAttributeGroup, _allergensGroupId);
  });
}
