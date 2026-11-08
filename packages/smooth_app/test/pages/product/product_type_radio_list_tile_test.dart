import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/product/add_new_product/product_type_radio_list_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/mocks.dart';

Future<UserPreferences> _pumpTile(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(mockSharedPreferences());
  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();
  await userPreferences.setTheme(THEME_LIGHT);
  late ProductPreferences productPreferences;
  productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () => productPreferences.notifyListeners(),
    ),
  );

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      Scaffold(
        body: ProductTypeRadioListTile(
          productType: ProductType.food,
          checked: true,
          onChanged: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return userPreferences;
}

double _tickOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.ancestor(
        of: find.byType(icons.Check),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  testWidgets('A tile built as checked shows its tick', (
    WidgetTester tester,
  ) async {
    await _pumpTile(tester);

    expect(_tickOpacity(tester), 1.0);
  });

  testWidgets('A checked tile keeps its tick after a theme change', (
    WidgetTester tester,
  ) async {
    final UserPreferences userPreferences = await _pumpTile(tester);

    await userPreferences.setTheme(THEME_DARK);
    await tester.pumpAndSettle();

    expect(_tickOpacity(tester), 1.0);
  });
}
