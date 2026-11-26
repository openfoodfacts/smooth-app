import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/prices/prices_locations_page.dart';
import 'package:smooth_app/pages/prices/prices_products_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

Future<MockSmoothApp> _buildTestApp({
  required String theme,
  required Widget child,
}) async {
  SharedPreferences.setMockInitialValues(mockSharedPreferences());
  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();
  await userPreferences.setTheme(theme);

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
  await ProductQuery.initCountry(userPreferences);
  ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');

  return MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    ThemeProvider(userPreferences),
    TextContrastProvider(userPreferences),
    ColorProvider(userPreferences),
    child,
    localDatabase: MockLocalDatabase(),
  );
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

  group('PricesLocationsPage V2 layout', () {
    final GetLocationsResult locationsResult = GetLocationsResult()
      ..total = 1
      ..pageNumber = 1
      ..numberOfPages = 1
      ..items = <Location>[
        Location()
          ..locationId = 1
          ..locationType = LocationType.osm
          ..name = 'Carrefour Market'
          ..city = 'Paris'
          ..countryCode = 'fr'
          ..displayName =
              'Carrefour Market, 123 Rue de Rivoli, 75001 Paris, France'
          ..priceCount = 42
          ..userCount = 5
          ..productCount = 18
          ..proofCount = 9,
      ];

    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets('renders V2 scaffold and location card in $theme theme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          await _buildTestApp(
            theme: theme,
            child: PricesLocationsPage(locationsResult: locationsResult),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SmoothScaffold2), findsOneWidget);
        expect(find.byType(SmoothTopBar2), findsOneWidget);
        expect(find.textContaining('Carrefour Market'), findsWidgets);
        expect(find.text('42'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('18'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
      });
    }
  });

  group('PricesProductsPage V2 layout', () {
    final GetPriceProductsResult productsResult = GetPriceProductsResult()
      ..total = 1
      ..pageNumber = 1
      ..numberOfPages = 1
      ..items = <PriceProduct>[
        PriceProduct()
          ..productId = 1
          ..code = '3017620422003'
          ..name = 'Nutella'
          ..brands = 'Ferrero'
          ..quantityString = '400 g'
          ..priceCount = 12,
      ];

    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets('renders V2 scaffold and product card in $theme theme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          await _buildTestApp(
            theme: theme,
            child: PricesProductsPage(productsResult: productsResult),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SmoothScaffold2), findsOneWidget);
        expect(find.byType(SmoothTopBar2), findsOneWidget);
        expect(find.text('Nutella'), findsOneWidget);
        expect(find.text('Ferrero'), findsOneWidget);
        expect(find.text('400 g'), findsOneWidget);
      });
    }
  });
}
