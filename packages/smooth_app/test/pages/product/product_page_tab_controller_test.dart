import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/product/product_page/header/product_page_tabs.dart';
import 'package:smooth_app/pages/product/product_page/product_page_tab_controller.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/mocks.dart';

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

  Widget wrap(Product product) => MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    themeProvider,
    textContrastProvider,
    colorProvider,
    Material(
      child: ProductPageTabController(
        product: product,
        // Every tab suffix is mounted: they start network futures that would
        // otherwise end unhandled.
        childBuilder: (List<ProductPageTab> tabs, TabController controller) {
          return Column(
            children: <Widget>[
              TabBar(
                controller: controller,
                tabs: tabs
                    .map(
                      (ProductPageTab tab) => Tab(
                        child: Row(
                          children: <Widget>[
                            Text(tab.id, key: ValueKey<String>(tab.id)),
                            if (tab.suffix != null) tab.suffix!,
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller,
                  children: tabs
                      .map((ProductPageTab tab) => const SizedBox())
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  List<String?> tabEvents() => MatomoTracker.instance.queue
      .where(
        (Map<String, String> event) => event['e_n'] == 'productPageTabSelected',
      )
      .map((Map<String, String> event) => event['e_a'])
      .toList();

  Product product() => Product(barcode: '0000000000000');

  testWidgets('building the tabs sends nothing', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    expect(tabEvents(), isEmpty);
  });

  testWidgets('a tap sends one event with the tab id', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('prices')));
    await tester.pumpAndSettle();

    expect(tabEvents(), <String?>['prices']);
  });

  testWidgets('a swipe sends one event with the next tab id', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(TabBarView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();

    expect(tabEvents(), <String?>['prices']);
  });

  testWidgets('tapping the selected tab sends nothing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('for_me')));
    await tester.pumpAndSettle();

    expect(tabEvents(), isEmpty);
  });

  testWidgets('a refreshed product sends nothing and keeps counting taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();
    expect(tabEvents(), isEmpty);

    await tester.tap(find.byKey(const ValueKey<String>('prices')));
    await tester.pumpAndSettle();
    expect(tabEvents(), <String?>['prices']);
  });
}
