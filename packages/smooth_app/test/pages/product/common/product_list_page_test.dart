import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../../tests_utils/local_database_mock.dart';
import '../../../tests_utils/mocks.dart';

class _LocalDatabase extends MockLocalDatabase {
  @override
  late final UpToDateProductListProvider upToDateProductList =
      UpToDateProductListProvider(this);
}

void main() {
  group('ProductListPage empty state', () {
    late Directory directory;
    late _LocalDatabase localDatabase;
    late DaoProductList daoProductList;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'product_list_page_test_',
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

    for (final ({Size size, double textScale}) testCase
        in <({Size size, double textScale})>[
          (size: const Size(400.0, 800.0), textScale: 1.0), // portrait
          (size: const Size(800.0, 360.0), textScale: 1.0), // landscape
          (size: const Size(640.0, 320.0), textScale: 1.0), // compact landscape
          (
            size: const Size(640.0, 280.0),
            textScale: 1.8,
          ), // short + large text
        ]) {
      testWidgets(
        'does not overflow when empty at ${testCase.size} (scale ${testCase.textScale})',
        (WidgetTester tester) async {
          tester.view.physicalSize = testCase.size;
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

          await tester.pumpWidget(
            MockSmoothApp(
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
                  ).copyWith(textScaler: TextScaler.linear(testCase.textScale)),
                  child: ProductListPage(ProductList.history()),
                ),
              ),
              localDatabase: localDatabase,
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(ProductListPage), findsOneWidget);
        },
      );
    }
  });
}
