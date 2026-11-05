import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';
import 'package:smooth_app/pages/prices/price_image_container.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

Future<Widget> _wrapWithSmoothApp({
  required Widget child,
  bool isDark = false,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'init': true,
    'currentThemeMode': isDark ? 'Dark' : 'Light',
  });
  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();
  await userPreferences.setTheme(isDark ? 'Dark' : 'Light');
  final ThemeProvider themeProvider = ThemeProvider(userPreferences);
  final ColorProvider colorProvider = ColorProvider(userPreferences);
  final TextContrastProvider textContrastProvider = TextContrastProvider(
    userPreferences,
  );

  final ThemeData lightTheme = SmoothTheme.getThemeData(
    Brightness.light,
    themeProvider,
    () => colorProvider,
    () => textContrastProvider,
  );
  final ThemeData darkTheme = SmoothTheme.getThemeData(
    Brightness.dark,
    themeProvider,
    () => colorProvider,
    () => textContrastProvider,
  );

  return ChangeNotifierProvider<ThemeProvider>.value(
    value: themeProvider,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('PriceImageContainer tests', () {
    testWidgets('renders placeholder when imageProvider is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const PriceImageContainer(
            size: Size.square(80.0),
            placeholder: icons.Shop(size: 32.0),
            count: 5,
          ),
        ),
      );

      expect(find.byType(icons.Shop), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byType(icons.PriceTag), findsOneWidget);
    });

    testWidgets('renders without count badge when count is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const PriceImageContainer(
            size: Size.square(80.0),
            placeholder: icons.Profile(size: 32.0),
          ),
        ),
      );

      expect(find.byType(icons.Profile), findsOneWidget);
      expect(find.byType(icons.PriceTag), findsNothing);
    });
  });

  group('PriceHeaderContainer tests', () {
    testWidgets('renders title, subtitle, and placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const PriceHeaderContainer(
            placeholder: icons.Shop(size: 32.0),
            line1: 'Carrefour Market',
            line2: 'Paris, France',
            line3: '123 Rue de Rivoli',
            count: 42,
            semanticsLabel: 'Carrefour Market shop',
          ),
        ),
      );

      expect(find.text('Carrefour Market'), findsOneWidget);
      expect(find.text('Paris, France'), findsOneWidget);
      expect(find.text('123 Rue de Rivoli'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byType(icons.Shop), findsOneWidget);
    });

    testWidgets('constrains line3 to at most 2 lines with ellipsis', (
      WidgetTester tester,
    ) async {
      const String longAddress =
          'Centre Commercial E.Leclerc, Rue Pierre Dreyfus, Clichy, Nanterre, Hauts-de-Seine, Île-de-France, France métropolitaine, 92110, France';

      await tester.pumpWidget(
        _wrapWithApp(
          const PriceHeaderContainer(
            placeholder: icons.Shop(size: 32.0),
            line1: 'E.Leclerc',
            line2: 'Clichy, France',
            line3: longAddress,
            semanticsLabel: 'E.Leclerc',
          ),
        ),
      );

      final Text line3Text = tester.widget<Text>(find.text(longAddress));
      expect(line3Text.maxLines, 2);
      expect(line3Text.overflow, TextOverflow.ellipsis);
    });
  });

  group('PriceLocationWidget tests', () {
    testWidgets('renders Location information and priceCount in header', (
      WidgetTester tester,
    ) async {
      final Location location = Location()
        ..locationId = 101
        ..name = 'Monoprix'
        ..city = 'Lyon'
        ..country = 'France'
        ..countryCode = 'fr'
        ..displayName = 'Monoprix, Lyon, France'
        ..priceCount = 15
        ..userCount = 3
        ..productCount = 12
        ..proofCount = 2;

      await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

      expect(find.text('Monoprix'), findsOneWidget);
      expect(find.text('Lyon, France  🇫🇷'), findsOneWidget);
      expect(find.text('Monoprix, Lyon, France'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.byType(icons.Shop), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          '15 prices for Monoprix - Lyon, France  🇫🇷 (Monoprix, Lyon, France)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Location semantics label with singular price count', (
      WidgetTester tester,
    ) async {
      final Location location = Location()
        ..locationId = 102
        ..name = 'Carrefour'
        ..city = 'Paris'
        ..country = 'France'
        ..countryCode = 'fr'
        ..priceCount = 1;

      await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

      expect(find.text('Carrefour'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(
        find.bySemanticsLabel('1 price for Carrefour - Paris, France  🇫🇷'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders assembled location text directly when priceCount is null',
      (WidgetTester tester) async {
        final Location location = Location()
          ..locationId = 103
          ..name = "Bio c' Bon"
          ..city = 'Nice'
          ..country = 'France'
          ..countryCode = 'fr'
          ..priceCount = null;

        await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

        expect(find.text("Bio c' Bon"), findsOneWidget);
        expect(find.text('Nice, France  🇫🇷'), findsOneWidget);
        expect(
          find.bySemanticsLabel("Bio c' Bon - Nice, France  🇫🇷"),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'falls back to website domain for online stores without name/city',
      (WidgetTester tester) async {
        final Location location = Location()
          ..locationId = 104
          ..websiteUrl = 'https://rewe.de'
          ..priceCount = 42;

        await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

        expect(find.text('rewe.de'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
        expect(find.bySemanticsLabel('42 prices for rewe.de'), findsOneWidget);
      },
    );

    testWidgets(
      'falls back to localized unknown store when name and website are missing',
      (WidgetTester tester) async {
        final Location location = Location()
          ..locationId = 105
          ..priceCount = 5;

        await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

        expect(find.text('Unknown store'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets(
      'constrains long OSM address to at most 2 lines with ellipsis in PriceLocationWidget',
      (WidgetTester tester) async {
        const String longAddress =
            'Centre Commercial E.Leclerc, Rue Pierre Dreyfus, Clichy, Nanterre, Hauts-de-Seine, Île-de-France, France métropolitaine, 92110, France';
        final Location location = Location()
          ..locationId = 106
          ..name = 'E.Leclerc'
          ..city = 'Clichy'
          ..country = 'France'
          ..countryCode = 'fr'
          ..displayName = longAddress
          ..priceCount = 25;

        await tester.pumpWidget(_wrapWithApp(PriceLocationWidget(location)));

        expect(find.text(longAddress), findsOneWidget);
        final Text addressText = tester.widget<Text>(find.text(longAddress));
        expect(addressText.maxLines, 2);
        expect(addressText.overflow, TextOverflow.ellipsis);
      },
    );

    test(
      'getWebsiteDomain extracts host safely from various URLs and formats',
      () {
        expect(
          PriceLocationWidget.getWebsiteDomain('https://rewe.de'),
          'rewe.de',
        );
        expect(
          PriceLocationWidget.getWebsiteDomain('https://www.rewe.de/angebote'),
          'rewe.de',
        );
        expect(
          PriceLocationWidget.getWebsiteDomain(
            'http://sub.domain.co.uk:8080/path?query=1',
          ),
          'sub.domain.co.uk',
        );
        expect(PriceLocationWidget.getWebsiteDomain('rewe.de'), 'rewe.de');
        expect(PriceLocationWidget.getWebsiteDomain('www.rewe.de'), 'rewe.de');
        expect(PriceLocationWidget.getWebsiteDomain(null), isNull);
        expect(PriceLocationWidget.getWebsiteDomain(''), isNull);
        expect(PriceLocationWidget.getWebsiteDomain('   '), isNull);
        expect(PriceLocationWidget.getWebsiteDomain('invalid url :::'), isNull);
        expect(PriceLocationWidget.getWebsiteDomain('https://'), isNull);
      },
    );
  });

  group('PriceProductWidget tests', () {
    testWidgets('renders PriceProduct information and priceCount in header', (
      WidgetTester tester,
    ) async {
      final PriceProduct product = PriceProduct()
        ..code = '1234567890123'
        ..name = 'Organic Milk'
        ..brands = 'Lactel'
        ..quantity = 1
        ..quantityUnit = 'L'
        ..priceCount = 8;

      await tester.pumpWidget(_wrapWithApp(PriceProductWidget(product)));

      expect(find.text('Organic Milk'), findsOneWidget);
      expect(find.text('Lactel'), findsOneWidget);
      expect(find.text('1 L'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(
        find.bySemanticsLabel('8 prices for Organic Milk - Lactel (1 L)'),
        findsOneWidget,
      );
    });

    testWidgets('renders PriceProduct semantics label with singular count', (
      WidgetTester tester,
    ) async {
      final PriceProduct product = PriceProduct()
        ..code = '9876543210987'
        ..name = 'Oat Milk'
        ..brands = 'Oatly'
        ..quantity = 1
        ..quantityUnit = 'L'
        ..priceCount = 1;

      await tester.pumpWidget(_wrapWithApp(PriceProductWidget(product)));

      expect(find.text('Oat Milk'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(
        find.bySemanticsLabel('1 price for Oat Milk - Oatly (1 L)'),
        findsOneWidget,
      );
    });
  });

  group(
    'User / contributor accessibility semantics tests with PriceUserCard',
    () {
      testWidgets(
        'renders user header with plural prices_user_accessibility_summary',
        (WidgetTester tester) async {
          final PriceUser user = PriceUser(<String, dynamic>{
            'user_id': 'alex_contributor',
            'price_count': 10,
          });

          await tester.pumpWidget(
            await _wrapWithSmoothApp(child: PriceUserCard(user)),
          );

          expect(find.text('alex_contributor'), findsOneWidget);
          expect(find.text('10'), findsOneWidget);
          expect(find.byType(icons.Profile), findsOneWidget);
          expect(
            find.bySemanticsLabel('10 prices for alex_contributor'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders user header with singular prices_user_accessibility_summary',
        (WidgetTester tester) async {
          final PriceUser user = PriceUser(<String, dynamic>{
            'user_id': 'sam_shopper',
            'price_count': 1,
          });

          await tester.pumpWidget(
            await _wrapWithSmoothApp(child: PriceUserCard(user)),
          );

          expect(find.text('sam_shopper'), findsOneWidget);
          expect(find.text('1'), findsOneWidget);
          expect(find.byType(icons.Profile), findsOneWidget);
          expect(
            find.bySemanticsLabel('1 price for sam_shopper'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders user header with username directly when priceCount is null',
        (WidgetTester tester) async {
          final PriceUser user = PriceUser(<String, dynamic>{
            'user_id': 'anonymous_user',
          });

          await tester.pumpWidget(
            await _wrapWithSmoothApp(child: PriceUserCard(user)),
          );

          expect(find.text('anonymous_user'), findsOneWidget);
          expect(find.byType(icons.Profile), findsOneWidget);
          expect(find.bySemanticsLabel('anonymous_user'), findsOneWidget);
        },
      );
    },
  );

  group('Theme variations and dark mode', () {
    testWidgets(
      'PriceUserCard applies correct card color in light and dark mode',
      (WidgetTester tester) async {
        final PriceUser user = PriceUser(<String, dynamic>{
          'user_id': 'theme_test_user',
          'price_count': 42,
        });

        // Test Light Mode
        await tester.pumpWidget(
          await _wrapWithSmoothApp(child: PriceUserCard(user), isDark: false),
        );
        final SmoothCard lightCard = tester.widget<SmoothCard>(
          find.byType(SmoothCard),
        );
        expect(lightCard.color, isNull);

        // Test Dark Mode
        await tester.pumpWidget(
          await _wrapWithSmoothApp(child: PriceUserCard(user), isDark: true),
        );
        final SmoothCard darkCard = tester.widget<SmoothCard>(
          find.byType(SmoothCard),
        );
        expect(darkCard.color, const Color(0xFF201A17));
      },
    );

    testWidgets(
      'PriceLocationWidget renders correctly in dark theme with full SmoothTheme',
      (WidgetTester tester) async {
        final Location location = Location()
          ..locationId = 202
          ..name = "Bio c' Bon"
          ..city = 'Paris'
          ..country = 'France'
          ..countryCode = 'fr'
          ..priceCount = 27;

        await tester.pumpWidget(
          await _wrapWithSmoothApp(
            child: PriceLocationWidget(location),
            isDark: true,
          ),
        );

        expect(find.text("Bio c' Bon"), findsOneWidget);
        expect(find.text('27'), findsOneWidget);
        expect(find.byType(icons.Shop), findsOneWidget);
      },
    );
  });
}
