import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/search/search_page.dart';
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

class _SearchHelper extends SearchLocationHelper {
  @override
  List<String> getAllQueries(LocalDatabase localDatabase) => <String>[];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;

  setUpAll(() async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await mockMatomo();
    userPreferences = await UserPreferences.getUserPreferences();
  });

  testWidgets('uses the initial query supplied through SearchPageExtra', (
    WidgetTester tester,
  ) async {
    final ProductPreferences productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () {},
      ),
    );
    await productPreferences.init(PlatformAssetBundle());

    final ThemeProvider themeProvider = ThemeProvider(userPreferences);
    await tester.pumpWidget(
      Provider<FileLoader>.value(
        value: _NoRiveFile(),
        child: MockSmoothApp(
          userPreferences,
          UserManagementProvider(),
          productPreferences,
          themeProvider,
          TextContrastProvider(userPreferences),
          ColorProvider(userPreferences),
          SearchPage.fromExtra(
            SearchPageExtra(
              searchHelper: _SearchHelper(),
              initialQuery: 'Paris',
              autofocus: false,
            ),
          ),
          localDatabase: MockLocalDatabase(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Paris',
    );
  });
}
