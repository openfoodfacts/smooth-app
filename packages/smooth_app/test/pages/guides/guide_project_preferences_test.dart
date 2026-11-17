import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_page.dart';
import 'package:smooth_app/pages/food_preferences/preferences_page_projects.dart';
import 'package:smooth_app/pages/guides/guide/guide_open_beauty_facts.dart';
import 'package:smooth_app/pages/guides/guide/guide_open_pet_food_facts.dart';
import 'package:smooth_app/pages/guides/helpers/guides_extra.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

Future<void> _pumpGuide(WidgetTester tester, Widget guide) async {
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  SharedPreferences.setMockInitialValues(mockSharedPreferences());

  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();
  final ProductPreferences productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () {},
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
      guide,
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

void main() {
  late HttpOverrides? priorOverrides;

  setUp(() {
    priorOverrides = HttpOverrides.current;
    HttpOverrides.global = MockHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = priorOverrides;
  });

  testWidgets(
    'Open Beauty Facts guide shows beauty preferences tile and navigates',
    (WidgetTester tester) async {
      await _pumpGuide(tester, const GuideOpenBeautyFacts());

      final Finder descriptionFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextWithBoldParts &&
            widget.text.contains('Want to avoid comedogenic substances?') &&
            widget.text.contains('controversial components?'),
      );
      await tester.scrollUntilVisible(
        descriptionFinder,
        200.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(descriptionFinder, findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);

      final Finder tileFinder = find.byType(GuidesProjectPreferences);
      await tester.scrollUntilVisible(
        tileFinder,
        200.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(tileFinder, findsOneWidget);

      expect(
        find.descendant(
          of: tileFinder,
          matching: find.text('Preferences for cosmetics'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: tileFinder, matching: find.byType(PreferenceTile)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final Finder destinationFinder = find.byType(FoodPreferencesPage);
      expect(destinationFinder, findsOneWidget);
      expect(
        tester.widget<FoodPreferencesPage>(destinationFinder).project,
        PreferencesPageProjects.beauty,
      );
    },
  );

  testWidgets(
    'Open Pet Food Facts guide shows pet food preferences tile and navigates',
    (WidgetTester tester) async {
      await _pumpGuide(tester, const GuideOpenPetFoodFacts());

      final Finder descriptionFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextWithBoldParts &&
            widget.text.contains('pet food ingredients') &&
            !widget.text.contains('cosmetic ingredients'),
      );
      await tester.scrollUntilVisible(
        descriptionFinder,
        200.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(descriptionFinder, findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);

      final Finder tileFinder = find.byType(GuidesProjectPreferences);
      await tester.scrollUntilVisible(
        tileFinder,
        200.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(tileFinder, findsOneWidget);

      expect(
        find.descendant(
          of: tileFinder,
          matching: find.text('Preferences for pet food'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: tileFinder, matching: find.byType(PreferenceTile)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final Finder destinationFinder = find.byType(FoodPreferencesPage);
      expect(destinationFinder, findsOneWidget);
      expect(
        tester.widget<FoodPreferencesPage>(destinationFinder).project,
        PreferencesPageProjects.pets,
      );
    },
  );
}
