import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/product/common/product_query_page.dart';
import 'package:smooth_app/pages/product/common/search_loading_screen.dart';
import 'package:smooth_app/query/keywords_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../tests_utils/local_database_mock.dart';
import '../../../tests_utils/mocks.dart';

class _NoRiveFile implements FileLoader {
  @override
  Future<File> file() => Completer<File>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyProductListSupplier extends ProductListSupplier {
  _EmptyProductListSupplier(super.productQuery, super.localDatabase);

  @override
  Future<String?> asyncLoad() async => null;

  @override
  ProductListSupplier? getRefreshSupplier() => null;
}

Future<void> _pumpWithScreen({
  required WidgetTester tester,
  required Size size,
  required double textScale,
  required Widget Function(MockLocalDatabase db) builder,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
  await ProductQuery.initCountry(userPreferences);
  ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
  final MockLocalDatabase localDatabase = MockLocalDatabase();

  await tester.pumpWidget(
    Provider<FileLoader>.value(
      value: _NoRiveFile(),
      child: MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        ThemeProvider(userPreferences),
        TextContrastProvider(userPreferences),
        ColorProvider(userPreferences),
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: builder(localDatabase),
          ),
        ),
        localDatabase: localDatabase,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  late HttpOverrides? priorOverrides;

  setUp(() {
    priorOverrides = HttpOverrides.current;
    HttpOverrides.global = MockHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = priorOverrides;
  });

  group('SearchLoadingScreen', () {
    for (final ({Size size, double textScale}) testCase
        in <({Size size, double textScale})>[
          (size: const Size(400.0, 800.0), textScale: 1.0),
          (size: const Size(800.0, 360.0), textScale: 1.0),
          (size: const Size(640.0, 260.0), textScale: 1.5),
        ]) {
      testWidgets(
        'does not overflow at ${testCase.size} (scale ${testCase.textScale})',
        (WidgetTester tester) async {
          await _pumpWithScreen(
            tester: tester,
            size: testCase.size,
            textScale: testCase.textScale,
            builder: (_) => const SearchLoadingScreen(title: 'Chocolate'),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(SearchLoadingScreen), findsOneWidget);
        },
      );
    }
  });

  group('ProductQueryPage empty state with world query', () {
    for (final ({Size size, double textScale}) testCase
        in <({Size size, double textScale})>[
          (size: const Size(400.0, 800.0), textScale: 1.0),
          (size: const Size(800.0, 360.0), textScale: 1.0),
          (size: const Size(640.0, 320.0), textScale: 1.0),
          (size: const Size(640.0, 300.0), textScale: 1.4),
        ]) {
      testWidgets(
        'does not overflow at ${testCase.size} (scale ${testCase.textScale})',
        (WidgetTester tester) async {
          await _pumpWithScreen(
            tester: tester,
            size: testCase.size,
            textScale: testCase.textScale,
            builder: (MockLocalDatabase db) => ProductQueryPage(
              productListSupplier: _EmptyProductListSupplier(
                KeywordsProductQuery(
                  'Chocolate',
                  productType: ProductType.food,
                  world: false,
                ),
                db,
              ),
              name: 'Chocolate',
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(ProductQueryPage), findsOneWidget);
        },
      );
    }
  });
}
