import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Price Location display (no price data here).
class PriceLocationWidget extends StatelessWidget {
  const PriceLocationWidget(this.location);

  final Location location;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String? title = getLocationTitle(location);
    final String name =
        location.name ?? title ?? appLocalizations.prices_entry_shop_not_found;
    final String? city = location.city;
    final String? country = location.country;
    final String? countryEmoji = EmojiHelper.getCountryEmoji(
      _getCountry(location),
    );

    final StringBuffer line2Buffer = StringBuffer();
    if (city != null && city.isNotEmpty) {
      line2Buffer.write(city);
    }
    if (country != null && country.isNotEmpty) {
      if (line2Buffer.isNotEmpty) {
        line2Buffer.write(', ');
      }
      line2Buffer.write(country);
    }
    if (countryEmoji != null) {
      if (line2Buffer.isNotEmpty) {
        line2Buffer.write('  ');
      }
      line2Buffer.write(countryEmoji);
    }
    final String? line2 = line2Buffer.isNotEmpty
        ? line2Buffer.toString()
        : null;

    final String? line3 =
        location.displayName != null &&
            location.displayName != name &&
            location.displayName != line2
        ? location.displayName
        : null;

    final int? priceCount = location.priceCount;

    return PriceHeaderContainer(
      placeholder: const icons.Shop(size: 32.0),
      line1: name,
      line2: line2,
      line3: line3,
      count: priceCount,
      semanticsLabel: _generateSemanticsLabel(
        appLocalizations,
        name,
        line2,
        line3,
        priceCount,
      ),
    );
  }

  String _generateSemanticsLabel(
    AppLocalizations appLocalizations,
    String name,
    String? line2,
    String? line3,
    int? priceCount,
  ) {
    final StringBuffer result = StringBuffer(name);
    if (line2 != null) {
      result.write(' - $line2');
    }
    if (line3 != null) {
      result.write(' ($line3)');
    }
    return appLocalizations.prices_product_accessibility_summary(
      priceCount ?? 0,
      result.toString(),
    );
  }

  static String? getLocationTitle(final Location? location) {
    if (location == null) {
      return null;
    }
    final StringBuffer result = StringBuffer();
    final String? countryEmoji = EmojiHelper.getCountryEmoji(
      _getCountry(location),
    );
    if (location.name != null) {
      result.write(location.name);
    }
    if (location.city != null) {
      if (result.isNotEmpty) {
        result.write(', ');
      }
      result.write(location.city);
    }
    if (countryEmoji != null) {
      if (result.isNotEmpty) {
        result.write('  ');
      }
      result.write(countryEmoji);
    }
    if (result.isEmpty) {
      return null;
    }
    return result.toString();
  }

  static OpenFoodFactsCountry? _getCountry(final Location location) =>
      OpenFoodFactsCountry.fromOffTag(location.countryCode);

  static Future<void> showLocationPrices({
    required final int locationId,
    required final BuildContext context,
  }) async => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => PricesPage(
        GetPricesModel(
          parameters: GetPricesModel.getStandardPricesParameters()
            ..locationId = locationId,
          displayEachLocation: false,
          uri: OpenPricesAPIClient.getUri(
            path: 'locations/$locationId',
            uriHelper: ProductQuery.uriPricesHelper,
          ),
          title: AppLocalizations.of(
            context,
          ).all_search_prices_top_location_single_title,
        ),
      ),
    ),
  );
}
