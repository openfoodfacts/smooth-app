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
    });
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
    });
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
