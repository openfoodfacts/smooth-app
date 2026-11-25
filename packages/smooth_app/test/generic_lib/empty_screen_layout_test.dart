import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/empty_screen_layout.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/local_database_mock.dart';
import '../tests_utils/mocks.dart';

Future<void> _pumpEmptyScreen({
  required WidgetTester tester,
  required Size size,
  required double textScale,
  required bool insideSliver,
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

  const EmptyScreenLayout layout = EmptyScreenLayout(
    icon: Icon(Icons.location_off),
    title: 'No locations found',
    explanation: 'There are no locations yet. Try adding a price with a receipt to see locations here.',
  );

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
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: insideSliver
                ? const CustomScrollView(
                    slivers: <Widget>[SliverFillRemaining(child: layout)],
                  )
                : layout,
          ),
        ),
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

void main() {
  group('EmptyScreenLayout', () {
    for (final ({Size size, double textScale, bool insideSliver}) testCase
        in <({Size size, double textScale, bool insideSliver})>[
          (size: const Size(400.0, 800.0), textScale: 1.0, insideSliver: false),
          (size: const Size(800.0, 360.0), textScale: 1.0, insideSliver: false),
          (size: const Size(800.0, 360.0), textScale: 1.0, insideSliver: true),
          (size: const Size(640.0, 280.0), textScale: 1.5, insideSliver: true),
        ]) {
      testWidgets(
        'does not overflow at ${testCase.size} (scale ${testCase.textScale}, sliver: ${testCase.insideSliver})',
        (WidgetTester tester) async {
          await _pumpEmptyScreen(
            tester: tester,
            size: testCase.size,
            textScale: testCase.textScale,
            insideSliver: testCase.insideSliver,
          );

          expect(tester.takeException(), isNull);
          expect(find.text('No locations found'), findsOneWidget);
        },
      );
    }
  });
}
