import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/favorite_location_helper.dart';
import 'package:smooth_app/pages/locations/favorite_locations_page.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/prices_root.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/favorite_locations_test_database.dart';
import '../../tests_utils/mocks.dart';

const OsmLocation _store = OsmLocation(
  osmId: 123,
  osmType: LocationOSMType.node,
  longitude: 2.3,
  latitude: 48.8,
  name: 'Local store',
  city: 'Paris',
);

class _UnavailableAnimations extends Mock implements rive.FileLoader {
  @override
  Future<rive.File> file() async =>
      throw Exception('Animations disabled in tests');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FavoriteLocationsTestStorage storage;
  late UserPreferences preferences;
  late ThemeProvider theme;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    preferences = await UserPreferences.getUserPreferences();
    theme = ThemeProvider(preferences);
    await ProductQuery.setCountry(preferences, 'fr');
    ProductQuery.setLanguage(null, preferences, languageCode: 'en');
    await mockMatomo();
    await const LazyCounterPrices(
      null,
    ).setLocalCount(100, preferences, notify: false);
  });

  setUp(() async {
    storage = FavoriteLocationsTestStorage();
    await storage.init(inMemory: true);
  });

  tearDown(() => storage.delete());

  Future<void> settleStorage(WidgetTester tester) async {
    await tester.runAsync(() async {
      await storage.localDatabase.database.rawQuery('SELECT 1');
      await Hive.box<List<String>>('stringList').flush();
    });
    await tester.pumpAndSettle();
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    Widget child = const FavoriteLocationsPage(),
  }) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<rive.FileLoader>(create: (_) => _UnavailableAnimations()),
          ChangeNotifierProvider<LocalDatabase>.value(
            value: storage.localDatabase,
          ),
          ChangeNotifierProvider<UserPreferences>.value(value: preferences),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: SmoothTheme.getThemeData(
            Brightness.light,
            theme,
            () => ColorProvider(preferences),
            () => TextContrastProvider(preferences),
          ),
        ),
      ),
    );
    await settleStorage(tester);
  }

  testWidgets('Open Prices settings opens favorite stores without signing in', (
    WidgetTester tester,
  ) async {
    OpenFoodAPIConfiguration.globalUser = null;
    await pumpPage(
      tester,
      child: ChangeNotifierProvider<PreferencesRootSearchController>(
        create: (_) => PreferencesRootSearchController(),
        child: const PricesRoot(title: 'Open Prices'),
      ),
    );
    await tester.tap(find.text('Favorite stores'));
    await settleStorage(tester);
    expect(find.byType(FavoriteLocationsPage), findsOneWidget);
    expect(find.textContaining('No favorite stores yet.'), findsOneWidget);
  });

  testWidgets('empty state offers store search and cancellation adds nothing', (
    WidgetTester tester,
  ) async {
    await DaoOsmLocation(storage.localDatabase).put(_store);
    await pumpPage(tester);
    expect(find.textContaining('No favorite stores yet.'), findsOneWidget);

    await tester.tap(find.byType(SmoothLargeButtonWithIcon));
    await settleStorage(tester);
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No favorite stores yet.'), findsOneWidget);
    expect(
      await FavoriteLocationHelper().getFavorites(storage.localDatabase),
      isEmpty,
    );
  });

  testWidgets(
    'selecting a recent store adds it once and removal keeps history',
    (WidgetTester tester) async {
      await DaoOsmLocation(storage.localDatabase).put(_store);
      await pumpPage(tester);

      for (int i = 0; i < 2; i++) {
        await tester.tap(find.byType(SmoothLargeButtonWithIcon));
        await settleStorage(tester);
        await tester.tap(find.text(_store.name!));
        await settleStorage(tester);
        expect(find.text(_store.name!), findsOneWidget);
        expect(find.byTooltip('Remove from favorites'), findsOneWidget);
      }

      await tester.tap(find.byTooltip('Remove from favorites'));
      await settleStorage(tester);
      expect(find.textContaining('No favorite stores yet.'), findsOneWidget);
      expect(
        await DaoOsmLocation(storage.localDatabase).getAll(),
        hasLength(1),
      );
    },
  );

  testWidgets('search result selection persists store details and favorite', (
    WidgetTester tester,
  ) async {
    await http.runWithClient(
      () async {
        await pumpPage(tester);
        await tester.tap(find.byType(SmoothLargeButtonWithIcon));
        await settleStorage(tester);
        await tester.enterText(find.byType(TextField), 'Local store Paris');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(find.text(_store.name!), findsOneWidget);

        await tester.tap(find.text(_store.name!));
        await settleStorage(tester);
        expect(find.byType(FavoriteLocationsPage), findsOneWidget);
        expect(find.byType(SearchPage), findsNothing);
        expect(find.text(_store.name!), findsOneWidget);
        expect(
          FavoriteLocationHelper().isFavorite(storage.localDatabase, _store),
          isTrue,
        );
        expect(
          (await DaoOsmLocation(storage.localDatabase).getAll()).single.name,
          _store.name,
        );
      },
      () => MockClient((http.Request request) async {
        expect(request.url.host, 'photon.komoot.io');
        return http.Response(
          jsonEncode(<String, Object>{
            'type': 'FeatureCollection',
            'features': <Object>[
              <String, Object>{
                'geometry': <String, Object>{
                  'type': 'Point',
                  'coordinates': <double>[_store.longitude, _store.latitude],
                },
                'properties': <String, Object>{
                  'osm_type': 'N',
                  'osm_id': _store.osmId,
                  'name': _store.name!,
                  'city': _store.city!,
                },
              },
            ],
          }),
          200,
        );
      }),
    );
  });

  testWidgets('missing details remain visible and removable', (
    WidgetTester tester,
  ) async {
    await DaoStringList(
      storage.localDatabase,
    ).add(DaoStringList.keyPriceStores, 'LocationOSMType.node-123');
    await pumpPage(tester);
    expect(
      find.textContaining('Store details are unavailable.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Remove from favorites'));
    await settleStorage(tester);
    expect(find.textContaining('No favorite stores yet.'), findsOneWidget);
  });

  testWidgets('existing search favorite control updates the settings page', (
    WidgetTester tester,
  ) async {
    await DaoOsmLocation(storage.localDatabase).put(_store);
    await pumpPage(tester);
    await tester.tap(find.byType(SmoothLargeButtonWithIcon));
    await settleStorage(tester);
    final Finder tile = find.widgetWithText(ListTile, _store.name!);
    await tester.tap(
      find.descendant(of: tile, matching: find.byType(IconButton)).first,
    );
    await settleStorage(tester);
    await tester.tap(find.byTooltip('Close'));
    await settleStorage(tester);
    expect(find.text(_store.name!), findsOneWidget);

    await tester.runAsync(
      () => FavoriteLocationHelper().setFavorite(
        storage.localDatabase,
        _store,
        false,
      ),
    );
    await settleStorage(tester);
    expect(find.textContaining('No favorite stores yet.'), findsOneWidget);
  });

  testWidgets('stores added from settings are available in the price picker', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(
      () => FavoriteLocationHelper().setFavorite(
        storage.localDatabase,
        _store,
        true,
      ),
    );
    final PriceModel priceModel = PriceModel(
      proofType: ProofType.priceTag,
      currency: Currency.EUR,
      multipleProducts: false,
    );
    OsmLocation? selected;
    await pumpPage(
      tester,
      child: ChangeNotifierProvider<PriceModel>.value(
        value: priceModel,
        child: Scaffold(
          body: PriceLocationCard(
            onLocationChanged: (OsmLocation location) => selected = location,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SmoothLargeButtonWithIcon));
    await settleStorage(tester);
    expect(find.text(_store.name!), findsOneWidget);
    await tester.tap(find.text(_store.name!));
    await settleStorage(tester);
    expect(selected?.osmId, _store.osmId);
    expect(selected?.osmType, _store.osmType);
    priceModel.dispose();
  });
}
