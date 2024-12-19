import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Price Location display (no price data here).
class PriceLocationWidget extends StatelessWidget {
  const PriceLocationWidget(
    this.location,
  );

  final Location location;

  @override
  Widget build(BuildContext context) {
    final String? title = getLocationTitle(location);
    return ListTile(
      leading: const Icon(PriceButton.locationIconData),
      title: title == null
          ? null
          : Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      subtitle: location.displayName == null
          ? null
          : Text(
              location.displayName!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
  }) async =>
      Navigator.of(context).push(
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
              title: AppLocalizations.of(context)
                  .all_search_prices_top_location_single_title,
            ),
          ),
        ),
      );
}
