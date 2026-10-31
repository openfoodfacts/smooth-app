import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/attribute_button.dart';

import '../tests_utils/mocks.dart';

void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();
    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    await userPreferences.init(productPreferences);
    await ProductQuery.setCountry(userPreferences, 'fr');
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
    await mockMatomo();
  });

  setUp(() {
    MatomoTracker.instance.dropActions();
  });

  const List<String> importanceIds = <String>[
    PreferenceImportance.ID_NOT_IMPORTANT,
    PreferenceImportance.ID_IMPORTANT,
    PreferenceImportance.ID_VERY_IMPORTANT,
    PreferenceImportance.ID_MANDATORY,
  ];

  Future<void> openEditMode(WidgetTester tester, Attribute attribute) async {
    await tester.pumpWidget(
      MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        themeProvider,
        textContrastProvider,
        colorProvider,
        Material(child: AttributeButton(attribute, productPreferences)),
      ),
    );
    await tester.tap(find.byType(ListTile).at(1));
    await tester.pump();
  }

  testWidgets('choosing another importance sends the attribute id', (
    WidgetTester tester,
  ) async {
    final Attribute attribute = Attribute(
      id: Attribute.ATTRIBUTE_VEGAN,
      name: 'Vegan',
    );
    final String current = productPreferences.getImportanceIdForAttributeId(
      attribute.id!,
    );
    await openEditMode(tester, attribute);

    await tester.tap(
      find.byType(ListTile).at(importanceIds.indexOf(current) == 0 ? 2 : 1),
    );
    await tester.pump();

    final Map<String, String> event = MatomoTracker.instance.queue.single;
    expect(event['e_n'], 'foodPreferenceSaved');
    expect(event['e_c'], 'food preferences');
    expect(event['e_a'], Attribute.ATTRIBUTE_VEGAN);
  });

  testWidgets('choosing the current importance sends nothing', (
    WidgetTester tester,
  ) async {
    final Attribute attribute = Attribute(
      id: Attribute.ATTRIBUTE_VEGETARIAN,
      name: 'Vegetarian',
    );
    final String current = productPreferences.getImportanceIdForAttributeId(
      attribute.id!,
    );
    await openEditMode(tester, attribute);

    await tester.tap(
      find.byType(ListTile).at(1 + importanceIds.indexOf(current)),
    );
    await tester.pump();

    expect(MatomoTracker.instance.queue, isEmpty);
  });
}
