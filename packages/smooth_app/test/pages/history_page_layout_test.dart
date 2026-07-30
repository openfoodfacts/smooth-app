import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/goldens.dart';
import '../tests_utils/local_database_mock.dart';
import '../tests_utils/mocks.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    // The page reads its barcodes from a hive box, which must exist even empty.
    hiveDirectory = Directory.systemTemp.createTempSync('history_page_test');
    Hive.init(hiveDirectory.path);
    final DaoProductList daoProductList = DaoProductList(MockLocalDatabase());
    daoProductList.registerAdapter();
    await daoProductList.init();
  });

  tearDownAll(() async {
    await Hive.close();
    hiveDirectory.deleteSync(recursive: true);
  });

  group('HistoryPage looks as expected', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        // The default 800x600 surface is landscape, where the floating action
        // button overlaps the empty state text. These are a Pixel 9's metrics.
        tester.view.physicalSize = const Size(1080, 2424);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        late UserPreferences userPreferences;
        late ProductPreferences productPreferences;
        late ThemeProvider themeProvider;
        late ColorProvider colorProvider;
        late TextContrastProvider textContrastProvider;

        SharedPreferences.setMockInitialValues(mockSharedPreferences());

        userPreferences = await UserPreferences.getUserPreferences();
        userPreferences.setTheme(theme);

        productPreferences = ProductPreferences(
          ProductPreferencesSelection(
            setImportance: userPreferences.setImportance,
            getImportance: userPreferences.getImportance,
            notify: () => productPreferences.notifyListeners(),
          ),
        );

        await productPreferences.init(PlatformAssetBundle());
        await userPreferences.init(productPreferences);
        themeProvider = ThemeProvider(userPreferences);
        colorProvider = ColorProvider(userPreferences);
        textContrastProvider = TextContrastProvider(userPreferences);

        await tester.pumpWidget(
          MockSmoothApp(
            userPreferences,
            UserManagementProvider(),
            productPreferences,
            themeProvider,
            textContrastProvider,
            colorProvider,
            const HistoryPage(),
            localDatabase: MockLocalDatabase(),
          ),
        );
        await tester.pump();

        await expectGoldenMatches(
          find.byType(HistoryPage),
          'history_page-${theme.toLowerCase()}.png',
        );
        expect(tester, meetsGuideline(textContrastGuideline));
        expect(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(tester, meetsGuideline(iOSTapTargetGuideline));
        expect(tester, meetsGuideline(androidTapTargetGuideline));
      });
    }
  });
}
