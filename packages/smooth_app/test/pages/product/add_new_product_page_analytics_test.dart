import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/add_new_product/add_new_product_page.dart';
import 'package:smooth_app/pages/product/add_new_product_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

class _UpToDateProductProvider extends UpToDateProductProvider {
  _UpToDateProductProvider(super.localDatabase);

  @override
  Product getLocalUpToDate(final Product initialProduct) => initialProduct;
}

class _LocalDatabase extends MockLocalDatabase {
  _LocalDatabase() {
    _upToDate = _UpToDateProductProvider(this);
  }

  late final UpToDateProductProvider _upToDate;

  @override
  UpToDateProductProvider get upToDate => _upToDate;
}

void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;

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
    ProductQuery.setQueryType(userPreferences);
    await mockMatomo();
  });

  setUp(() {
    MatomoTracker.instance.dropActions();
  });

  Widget wrap(Widget page) => MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    ThemeProvider(userPreferences),
    TextContrastProvider(userPreferences),
    ColorProvider(userPreferences),
    page,
    localDatabase: _LocalDatabase(),
  );

  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  List<String?> eventNames() => MatomoTracker.instance.queue
      .map((Map<String, String> event) => event['e_n'])
      .toList();

  Map<String, String> singleEvent(String name) => MatomoTracker.instance.queue
      .singleWhere((Map<String, String> event) => event['e_n'] == name);

  Product foodProduct() =>
      Product(barcode: '1234567890123')..productType = ProductType.food;

  testWidgets('new product page reports the step it was closed on', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(AddNewProductPage.fromBarcode('1234567890123')),
    );
    await tester.pump();
    await close(tester);

    final Map<String, String> event = singleEvent('closeNewProductPage');
    expect(event['e_c'], 'new product');
    expect(event['e_a'], '1/6');
    expect(int.tryParse(event['e_v']!), isNotNull);
  });

  testWidgets('fast-track page reports the step reached by swiping', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AddNewProductPage.fromProduct(
          foodProduct(),
          isLoggedInMandatory: false,
        ),
      ),
    );
    await tester.pump();
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();
    await close(tester);

    expect(singleEvent('closeFastTrackProductPage')['e_a'], '2/3');
  });

  test('a field already filled on open is not reported as added', () {
    AnalyticsProductTracker(
      analyticsEvent: AnalyticsEvent.categoriesFastTrackProductPage,
      barcode: '1234567890123',
      check: () => true,
    ).track();

    expect(eventNames(), isEmpty);
  });

  test('a field filled on the page is reported once', () {
    bool populated = false;
    final AnalyticsProductTracker tracker = AnalyticsProductTracker(
      analyticsEvent: AnalyticsEvent.categoriesFastTrackProductPage,
      barcode: '1234567890123',
      check: () => populated,
    );
    tracker.track();
    populated = true;
    tracker.track();
    tracker.track();

    expect(eventNames(), <String>['categoriesFastTrackProductPage']);
  });
}
