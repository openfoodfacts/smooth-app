import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';
import 'package:smooth_app/pages/prices/price_image_container.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
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

  group('User / contributor accessibility semantics tests', () {
    testWidgets(
      'renders user header with plural prices_user_accessibility_summary',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (BuildContext context) {
                final AppLocalizations appLocalizations = AppLocalizations.of(
                  context,
                );
                return PriceHeaderContainer(
                  placeholder: const icons.Profile(size: 32.0),
                  line1: 'alex_contributor',
                  count: 10,
                  semanticsLabel: appLocalizations
                      .prices_user_accessibility_summary(
                        10,
                        'alex_contributor',
                      ),
                );
              },
            ),
          ),
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
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (BuildContext context) {
                final AppLocalizations appLocalizations = AppLocalizations.of(
                  context,
                );
                return PriceHeaderContainer(
                  placeholder: const icons.Profile(size: 32.0),
                  line1: 'sam_shopper',
                  count: 1,
                  semanticsLabel: appLocalizations
                      .prices_user_accessibility_summary(1, 'sam_shopper'),
                );
              },
            ),
          ),
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
        await tester.pumpWidget(
          _wrapWithApp(
            const PriceHeaderContainer(
              placeholder: icons.Profile(size: 32.0),
              line1: 'anonymous_user',
              semanticsLabel: 'anonymous_user',
            ),
          ),
        );

        expect(find.text('anonymous_user'), findsOneWidget);
        expect(find.byType(icons.Profile), findsOneWidget);
        expect(find.bySemanticsLabel('anonymous_user'), findsOneWidget);
      },
    );
  });

  group('Theme variations and dark mode', () {
    testWidgets('renders properly in dark mode', (WidgetTester tester) async {
      final Location location = Location()
        ..locationId = 202
        ..name = "Bio c' Bon"
        ..city = 'Paris'
        ..country = 'France'
        ..countryCode = 'fr'
        ..priceCount = 27;

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PriceLocationWidget(location)),
        ),
      );

      expect(find.text("Bio c' Bon"), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
    });
  });
}
