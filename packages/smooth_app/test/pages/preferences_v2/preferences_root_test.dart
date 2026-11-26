import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/food_preferences/pages/introduction_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/summary_page.dart';
import 'package:smooth_app/pages/food_preferences/preferences_page_projects.dart';
import 'package:smooth_app/pages/food_preferences/widgets/attribute_group_page.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_navigation_bar.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/roots/default_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/faq_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

Future<void> _pumpRoot(WidgetTester tester, PreferencesRoot root) async {
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

  MatomoTracker.instance.dropActions();
  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      ChangeNotifierProvider<PreferencesRootSearchController>(
        create: (_) => PreferencesRootSearchController(),
        child: root,
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

List<String> _screenViews() => MatomoTracker.instance.queue
    .map((Map<String, String> event) => event['action_name'] ?? '')
    .where((String name) => name.isNotEmpty)
    .toList();

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await mockMatomo();
    await ProductQuery.setCountry(
      await UserPreferences.getUserPreferences(),
      'fr',
    );
  });

  testWidgets('a pushed settings root reports one screen view', (
    WidgetTester tester,
  ) async {
    await _pumpRoot(tester, const FaqRoot(title: 'FAQ'));

    expect(_screenViews(), <String>['Opened faq_page']);
  });

  testWidgets('the settings tab root reports no screen view', (
    WidgetTester tester,
  ) async {
    await _pumpRoot(
      tester,
      const DefaultPreferencesRoot(
        cards: <PreferenceCard>[],
        customAppBar: SliverToBoxAdapter(child: SizedBox()),
      ),
    );

    expect(_screenViews(), isEmpty);
  });

  testWidgets('removed top bar stops listening to scrolling', (
    WidgetTester tester,
  ) async {
    final UserPreferences userPreferences =
        await UserPreferences.getUserPreferences();
    final ProductPreferences productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () {},
      ),
    );
    final ScrollController scrollController = ScrollController();
    final ValueNotifier<bool> showTopBar = ValueNotifier<bool>(true);
    addTearDown(scrollController.dispose);
    addTearDown(showTopBar.dispose);

    await tester.pumpWidget(
      MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        ThemeProvider(userPreferences),
        TextContrastProvider(userPreferences),
        ColorProvider(userPreferences),
        PrimaryScrollController(
          controller: scrollController,
          child: ValueListenableBuilder<bool>(
            valueListenable: showTopBar,
            builder: (BuildContext context, bool show, Widget? child) =>
                Scaffold(
                  appBar: show
                      ? const SmoothTopBar2(
                          title: 'Preferences',
                          productType: ProductType.food,
                        )
                      : null,
                  body: ListView(
                    controller: scrollController,
                    children: const <Widget>[SizedBox(height: 2000)],
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    showTopBar.value = false;
    await tester.pumpAndSettle();
    scrollController.jumpTo(100);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reopening completed food preferences shows the editable summary',
    (
      WidgetTester tester,
    ) async {
      final HttpOverrides? previousOverrides = HttpOverrides.current;
      HttpOverrides.global = MockHttpOverrides();
      addTearDown(() => HttpOverrides.global = previousOverrides);
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2;
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
      await ProductQuery.setCountry(userPreferences, 'fr');
      ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
      await userPreferences.setImportanceForProject(
        'test_cosmetic_attribute',
        PreferenceImportance.ID_MANDATORY,
        PreferencesPageProjects.beauty,
      );
      expect(userPreferences.hasCompletedFoodPreferencesWizard, isFalse);
      await tester.pumpWidget(
        MockSmoothApp(
          userPreferences,
          UserManagementProvider(),
          productPreferences,
          ThemeProvider(userPreferences),
          TextContrastProvider(userPreferences),
          ColorProvider(userPreferences),
          PreferencesPage(),
          localDatabase: MockLocalDatabase(),
        ),
      );
      await tester.pumpAndSettle();

      final Finder foodTile = find.text('Food Preferences');
      await tester.tap(foodTile);
      await tester.pumpAndSettle();
      expect(find.byType(IntroductionPage), findsOneWidget);

      // Leaving without validating must not mark the wizard as complete.
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pumpAndSettle();
      await tester.tap(foodTile);
      await tester.pumpAndSettle();
      expect(find.byType(IntroductionPage), findsOneWidget);

      Future<void> goToSummary() async {
        // Loop up to the number of attribute groups + introduction page.
        for (int i = 0; i <= productPreferences.attributeGroups!.length; i++) {
          final FoodPreferencesNavigationBar navigation = tester.widget(
            find.byType(FoodPreferencesNavigationBar),
          );
          if (navigation.isSummaryPage) {
            break;
          }
          await tester.tap(
            find.byKey(FoodPreferencesNavigationBar.positiveButtonKey),
          );
          await tester.pumpAndSettle();
        }
        expect(find.byType(SummaryPage), findsOneWidget);
      }

      await goToSummary();
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pumpAndSettle();
      await tester.tap(foodTile);
      await tester.pumpAndSettle();
      expect(find.byType(IntroductionPage), findsOneWidget);
      await goToSummary();
      expect(
        userPreferences.hasCompletedFoodPreferencesWizard,
        isFalse,
      );

      // find and tap validate button on summary page that closes the wizard
      await tester.tap(
        find.byKey(FoodPreferencesNavigationBar.positiveButtonKey),
      );
      await tester.pumpAndSettle();
      expect(
        userPreferences.hasCompletedFoodPreferencesWizard,
        isTrue,
      );
      expect(
        (await SharedPreferences.getInstance()).getBool(
          'preferences_wizard_completed_food',
        ),
        isTrue,
      );
      // reopening completed food preferences
      await tester.tap(foodTile);
      await tester.pumpAndSettle();
      expect(find.byType(SummaryPage), findsOneWidget);
      await tester.tap(find.byTooltip('Edit').first);
      await tester.pump();
      expect(find.byType(SummaryPage), findsNothing);
      expect(find.byType(AttributeGroupPage), findsOneWidget);
      expect(
        tester
            .widget<AttributeGroupPage>(find.byType(AttributeGroupPage))
            .attributeGroup,
        productPreferences.attributeGroups!.first,
      );
    },
  );
}
