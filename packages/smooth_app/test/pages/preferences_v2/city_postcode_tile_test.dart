import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/city_postcode_tile.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late ThemeProvider themeProvider;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    userPreferences = await UserPreferences.getUserPreferences();
    themeProvider = ThemeProvider(userPreferences);
  });

  setUp(() async {
    await userPreferences.setUserCityOrPostcode('');
  });

  testWidgets('saves the entered city or postcode', (
    WidgetTester tester,
  ) async {
    await _pumpTile(tester, userPreferences, themeProvider);

    await tester.tap(find.text('Your city or postcode').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Paris  ');
    final AppLocalizations appLocalizations = AppLocalizations.of(
      tester.element(find.byType(CityPostcodeTile)),
    );
    await tester.tap(find.text(appLocalizations.save.toUpperCase()));
    await tester.pumpAndSettle();

    expect(userPreferences.userCityOrPostcode, 'Paris');
    expect(find.text('Paris'), findsOneWidget);
    expect(
      find.text(
        'Saved on this device only. Used to prefill Open Prices store search and sent to OpenStreetMap only when you submit a search.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('cancel leaves the saved city or postcode unchanged', (
    WidgetTester tester,
  ) async {
    await userPreferences.setUserCityOrPostcode('Paris');
    await _pumpTile(tester, userPreferences, themeProvider);

    await tester.tap(find.text('Your city or postcode'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'London');
    final AppLocalizations appLocalizations = AppLocalizations.of(
      tester.element(find.byType(CityPostcodeTile)),
    );
    await tester.tap(find.text(appLocalizations.cancel.toUpperCase()));
    await tester.pumpAndSettle();

    expect(userPreferences.userCityOrPostcode, 'Paris');
  });
}

Future<void> _pumpTile(
  WidgetTester tester,
  UserPreferences userPreferences,
  ThemeProvider themeProvider,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserPreferences>.value(value: userPreferences),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            SmoothColorsThemeExtension.defaultValues(true),
          ],
        ),
        home: const Scaffold(
          body: CityPostcodeTile(title: 'Your city or postcode'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
