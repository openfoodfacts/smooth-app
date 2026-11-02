import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });

  late List<ProductPageTab> tabs;
  late TabController controller;

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
        childBuilder: (List<ProductPageTab> t, TabController c) {
          tabs = t;
          controller = c;
          return Column(
            children: <Widget>[
              // The suffixes start network futures that must end mounted.
              TabBar(
                controller: c,
                tabs: t
                    .map(
                      (ProductPageTab tab) => Tab(
                        child: Row(
                          children: <Widget>[
                            Text(tab.id),
                            if (tab.suffix != null) tab.suffix!,
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: c,
                  children: t
                      .map((ProductPageTab tab) => const SizedBox.expand())
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  Product product() => Product(barcode: '0000000000000');

  testWidgets('a new copy of the product during a swipe keeps the swipe', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('prices'));
    await tester.pumpAndSettle();

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(TabBarView)),
    );
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();

    await tester.pumpWidget(wrap(product()));
    await gesture.moveBy(const Offset(-300, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tabs[controller.index].id, 'folksonomy');
  });

  testWidgets('a new product with reordered tabs gets the new tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();
    final TabController before = controller;

    const List<String> order = <String>['folksonomy', 'prices', 'for_me'];
    await userPreferences.setProductPageTabs(order);
    addTearDown(() => userPreferences.setProductPageTabs(<String>[]));
    await tester.pumpWidget(wrap(product()));
    await tester.pumpAndSettle();

    expect(tabs.map((ProductPageTab tab) => tab.id).take(3), order);
    expect(controller, isNot(same(before)));
  });
}
