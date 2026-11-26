import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/common/search_loading_screen.dart';
import 'package:smooth_app/pages/product/contributor_products_loader_page.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

class _NoRiveFile implements FileLoader {
  @override
  Future<File> file() => Completer<File>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LocalDatabase extends MockLocalDatabase {
  @override
  late final UpToDateProductListProvider upToDateProductList =
      UpToDateProductListProvider(this);
}

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  late HttpOverrides? priorOverrides;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await ProductQuery.initCountry(await UserPreferences.getUserPreferences());
    mockMatomo();
  });

  setUp(() {
    priorOverrides = HttpOverrides.current;
    HttpOverrides.global = MockHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = priorOverrides;
  });

  group('Contributor deep-link resolution', () {
    test('captures /contributor/<userId> URLs', () {
      final Uri uri = Uri.parse(
        'https://world.openfoodfacts.org/contributor/teolemon',
      );
      expect(
        AppNavigator.resolveExternalDeepLink(
          Uri(path: uri.path, queryParameters: uri.queryParameters),
        ),
        equals(AppRoutes.CONTRIBUTOR_PRODUCTS('teolemon')),
      );
    });

    test('handles trailing slashes and URL-encoded usernames', () {
      final Uri withTrailingSlash = Uri.parse('/contributor/teolemon/');
      expect(
        AppNavigator.resolveExternalDeepLink(withTrailingSlash),
        equals(AppRoutes.CONTRIBUTOR_PRODUCTS('teolemon')),
      );

      final Uri encoded = Uri.parse('/contributor/john%20doe');
      expect(
        AppNavigator.resolveExternalDeepLink(encoded),
        equals(AppRoutes.CONTRIBUTOR_PRODUCTS('john doe')),
      );
    });

    test('falls back to external browser for incomplete or deeper paths', () {
      expect(
        AppNavigator.resolveExternalDeepLink(Uri.parse('/contributor')),
        equals(AppRoutes.EXTERNAL('contributor')),
      );
      expect(
        AppNavigator.resolveExternalDeepLink(
          Uri.parse('/contributor/teolemon/other'),
        ),
        equals(AppRoutes.EXTERNAL('contributor/teolemon/other')),
      );
    });
  });

  group('ContributorProductsLoaderPage', () {
    late Directory directory;
    late _LocalDatabase localDatabase;
    late DaoProductList daoProductList;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'contributor_loader_test_',
      );
      Hive.init(directory.path);
      localDatabase = _LocalDatabase();
      daoProductList = DaoProductList(localDatabase);
      daoProductList.registerAdapter();
      await daoProductList.init();
    });

    tearDown(() async {
      await Hive.close();
      Hive.resetAdapters();
      await directory.delete(recursive: true);
    });

    test('resolves cached contributor query supplier', () async {
      SharedPreferences.setMockInitialValues(mockSharedPreferences());
      final UserPreferences userPreferences =
          await UserPreferences.getUserPreferences();
      await ProductQuery.initCountry(userPreferences);
      ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');

      final PagedUserProductQuery query = PagedUserProductQuery(
        userId: 'teolemon',
        type: UserSearchType.CONTRIBUTOR,
        productType: ProductType.food,
      );
      await daoProductList.put(query.getProductList());

      final ProductListSupplier supplier =
          await ProductListSupplier.getBestSupplier(query, localDatabase);
      expect(supplier, isA<DatabaseProductListSupplier>());
    });

    testWidgets(
      'renders SearchLoadingScreen while resolving contributor query',
      (
        WidgetTester tester,
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
        await ProductQuery.initCountry(userPreferences);
        ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');

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
              const ContributorProductsLoaderPage(userId: 'teolemon'),
              localDatabase: localDatabase,
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SearchLoadingScreen), findsOneWidget);
        expect(find.textContaining('teolemon'), findsOneWidget);
      },
    );
  });
}
