import 'dart:io';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/roots/default_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/prices_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/square_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/pages/prices/prices_locations_page.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_products_page.dart';
import 'package:smooth_app/pages/prices/prices_stats_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/local_database_mock.dart';
import '../tests_utils/mocks.dart';

void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;
  late HttpOverrides? priorOverrides;

  setUpAll(() {
    GlobalVars.appStore = const MockedAppStore();
    GlobalVars.storeLabel = StoreLabel.Test;
    GlobalVars.scannerLabel = ScannerLabel.Test;
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'preferences-test');
  });

  setUp(() async {
    priorOverrides = HttpOverrides.current;
    HttpOverrides.global = MockHttpOverrides();
    OpenFoodAPIConfiguration.globalUser = null;
    userPreferences = await UserPreferences.getUserPreferences();
    await userPreferences.setTheme(THEME_LIGHT);
    await userPreferences.setDevMode(0);
    await userPreferences.setFlag(
      UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
      false,
    );
    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    await userPreferences.init(productPreferences);
    ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
    ProductQuery.setQueryType(userPreferences);
    await ProductQuery.setCountry(userPreferences, 'fr');
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
  });

  tearDown(() {
    HttpOverrides.global = priorOverrides;
    OpenFoodAPIConfiguration.globalUser = null;
    themeProvider.dispose();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        themeProvider,
        textContrastProvider,
        colorProvider,
        Builder(
          builder: (BuildContext context) => Localizations.override(
            context: context,
            locale: locale,
            child: PreferencesPage(),
          ),
        ),
        localDatabase: MockLocalDatabase(),
      ),
    );
    await tester.pump();
  }

  AppLocalizations localizations(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(PreferencesPage)));

  Future<void> search(WidgetTester tester, String query) async {
    final BuildContext context = tester.element(
      find.byType(DefaultPreferencesRoot).first,
    );
    context.read<PreferencesRootSearchController>().search(
      context,
      query,
      searchQueryCallback: (_) {},
    );
    await tester.pump();
  }

  Finder tileWithTitle(String title) => find.byWidgetPredicate(
    (Widget widget) => widget is PreferenceTile && widget.title == title,
  );

  testWidgets('individual Open Prices actions are globally searchable', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final AppLocalizations l10n = localizations(tester);
    for (final String title in <String>[
      l10n.prices_add_a_receipt,
      l10n.prices_add_price_tags,
      l10n.preferences_prices_newest_title,
      l10n.preferences_prices_top_contributors_title,
      l10n.all_search_prices_top_location_title,
      l10n.all_search_prices_top_product_title,
      l10n.preferences_prices_metrics_title,
    ]) {
      await search(tester, title.toUpperCase());
      expect(tileWithTitle(title), findsOneWidget);
    }
  });

  testWidgets('personal prices and proofs require a logged-in user', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final AppLocalizations l10n = localizations(tester);
    for (final String title in <String>[
      l10n.user_search_prices_title,
      l10n.user_search_proofs_title,
    ]) {
      await search(tester, title);
      expect(tileWithTitle(title), findsNothing);
    }

    OpenFoodAPIConfiguration.globalUser = const User(
      userId: 'prices-search-test',
      password: 'password',
    );
    await pumpPage(tester);
    for (final String title in <String>[
      l10n.user_search_prices_title,
      l10n.user_search_proofs_title,
    ]) {
      await search(tester, title);
      expect(tileWithTitle(title), findsOneWidget);
    }
  });

  testWidgets('bulk upload keeps its feature flag', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final String title = localizations(tester).prices_bulk_proof_upload_title;
    await search(tester, title);
    expect(tileWithTitle(title), findsNothing);

    await userPreferences.setFlag(
      UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
      true,
    );
    await tester.pump();
    expect(tileWithTitle(title), findsOneWidget);

    await userPreferences.setFlag(
      UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
      false,
    );
    await tester.pump();
    expect(tileWithTitle(title), findsNothing);
  });

  testWidgets('existing nested settings search still works', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final String title = localizations(tester).preferences_terms_of_use;
    await search(tester, title.toUpperCase());
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('Open Prices search uses translated labels and subtitles', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester, locale: const Locale('fr'));
    final AppLocalizations l10n = localizations(tester);
    final String title = l10n.prices_add_a_receipt;
    await search(tester, title.toUpperCase());
    expect(tileWithTitle(title), findsOneWidget);
    await search(tester, l10n.preferences_prices_add_receipt_subtitle);
    expect(tileWithTitle(title), findsOneWidget);
  });

  testWidgets('Open Prices web actions are searchable without duplicates', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final AppLocalizations l10n = localizations(tester);
    final BuildContext context = tester.element(find.byType(PreferencesPage));
    final Iterable<UrlPreferenceTile> webTiles =
        PricesRoot(title: l10n.preferences_prices_title)
            .getCards(context)
            .expand((PreferenceCard card) => card.tiles)
            .whereType<UrlPreferenceTile>();
    expect(webTiles, isNotEmpty);
    for (final UrlPreferenceTile tile in webTiles) {
      await search(tester, tile.title);
      final Finder result = find.byWidgetPredicate(
        (Widget widget) =>
            widget is UrlPreferenceTile && widget.title == tile.title,
      );
      expect(result, findsOneWidget);
      expect(tester.widget<UrlPreferenceTile>(result).url, tile.url);
      expect(find.text(tile.title), findsOneWidget);
    }
    await search(tester, l10n.preferences_prices_newest_title);
    expect(tileWithTitle(l10n.preferences_prices_newest_title), findsOneWidget);
  });

  testWidgets(
    'developer settings stay hidden until developer mode is enabled',
    (WidgetTester tester) async {
      await pumpPage(tester);
      final String title = localizations(
        tester,
      ).dev_preferences_reset_onboarding_title;
      await search(tester, title);
      expect(tileWithTitle(title), findsNothing);
      await userPreferences.setDevMode(1);
      await tester.pump();
      expect(tileWithTitle(title), findsOneWidget);
    },
  );

  testWidgets('Add Prices grid navigation keeps its own search controller', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);
    final BuildContext context = tester.element(
      find.byType(DefaultPreferencesRoot),
    );
    final PreferencesRootSearchController globalController = context
        .read<PreferencesRootSearchController>();
    final String title = localizations(tester).preferences_add_prices;
    final SquarePreferenceTile tile = tester.widget<SquarePreferenceTile>(
      tileWithTitle(title),
    );
    tile.onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(PricesRoot), findsOneWidget);
    final BuildContext pricesContext = tester.element(find.byType(PricesRoot));
    expect(
      pricesContext.read<PreferencesRootSearchController>(),
      isNot(same(globalController)),
    );
    expect(pricesContext.read<PreferencesRootSearchController>().query, isNull);
  });

  for (final bool loggedIn in <bool>[false, true]) {
    for (final ProofType proofType in <ProofType>[
      ProofType.receipt,
      ProofType.priceTag,
    ]) {
      testWidgets('add $proofType from search (logged in: $loggedIn)', (
        WidgetTester tester,
      ) async {
        if (loggedIn) {
          OpenFoodAPIConfiguration.globalUser = const User(
            userId: 'prices-search-test',
            password: 'password',
          );
        }
        await pumpPage(tester);
        final AppLocalizations l10n = localizations(tester);
        final String title = proofType == ProofType.receipt
            ? l10n.prices_add_a_receipt
            : l10n.prices_add_price_tags;
        await search(tester, title);
        await tester.tap(find.text(title));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        if (loggedIn) {
          final ProductPriceAddPage page = tester.widget<ProductPriceAddPage>(
            find.byType(ProductPriceAddPage),
          );
          expect(page.model.proofType, proofType);
        } else {
          expect(find.text(l10n.account_create_message), findsOneWidget);
          expect(find.byType(ProductPriceAddPage), findsNothing);
        }
      });
    }
  }

  for (final (String Function(AppLocalizations), Type) action
      in <(String Function(AppLocalizations), Type)>[
        (
          (AppLocalizations l10n) => l10n.preferences_prices_newest_title,
          PricesPage,
        ),
        (
          (AppLocalizations l10n) =>
              l10n.preferences_prices_top_contributors_title,
          PricesUsersPage,
        ),
        (
          (AppLocalizations l10n) => l10n.all_search_prices_top_location_title,
          PricesLocationsPage,
        ),
        (
          (AppLocalizations l10n) => l10n.all_search_prices_top_product_title,
          PricesProductsPage,
        ),
        (
          (AppLocalizations l10n) => l10n.preferences_prices_metrics_title,
          PricesStatsPage,
        ),
      ]) {
    testWidgets('global search opens ${action.$2}', (
      WidgetTester tester,
    ) async {
      await http.runWithClient(() async {
        await pumpPage(tester);
        final String title = action.$1(localizations(tester));
        await search(tester, title);
        await tester.tap(find.text(title));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(action.$2), findsOneWidget);
      }, () => MockClient((_) async => http.Response('{}', 500)));
    });
  }
}
