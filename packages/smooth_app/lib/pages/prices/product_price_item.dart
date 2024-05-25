import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Single product price widget.
class ProductPriceItem extends StatelessWidget {
  const ProductPriceItem(this.price);

  final Price price;

  @override
  Widget build(BuildContext context) {
    final String locale = ProductQuery.getLocaleString();
    final DateFormat dateFormat = DateFormat.yMd(locale);
    final DateFormat timeFormat = DateFormat.Hms(locale);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: price.currency.name,
    );
    final String? locationTitle = _getLocationTitle(price.location);
    final double? pricePerKg = _getPricePerKg(price);
    return SmoothCard(
      child: ListTile(
        title: Text(
          '${currencyFormat.format(price.price)}'
          '${pricePerKg == null ? '' : ' (${currencyFormat.format(pricePerKg)} / kg)'}'
          '   '
          '${dateFormat.format(price.date)}',
        ),
        subtitle: Wrap(
          spacing: MEDIUM_SPACE,
          children: <Widget>[
            if (locationTitle != null)
              ElevatedButton.icon(
                // TODO(monsieurtanuki): open a still-to-be-done "price x location" page
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined),
                label: Text(locationTitle),
              ),
            ElevatedButton.icon(
              // TODO(monsieurtanuki): open a still-to-be-done "price x user" page
              onPressed: () {},
              icon: const Icon(Icons.account_box),
              label: Text(price.owner),
            ),
            Tooltip(
              message: '${dateFormat.format(price.created)}'
                  ' '
                  '${timeFormat.format(price.created)}',
              child: ElevatedButton.icon(
                // TODO(monsieurtanuki): misleading "active" button
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: Text(
                  ProductQueryPageHelper.getDurationStringFromTimestamp(
                    price.created.millisecondsSinceEpoch,
                    context,
                    compact: true,
                  ),
                ),
              ),
            ),
            if (price.proof?.filePath != null)
              ElevatedButton(
                onPressed: () async => LaunchUrlHelper.launchURL(
                  // TODO(monsieurtanuki): probably won't work in TEST env
                  'https://prices.openfoodfacts.org/img/${price.proof?.filePath}',
                ),
                child: const Icon(Icons.image),
              ),
          ],
        ),
      ),
    );
  }

  static double? _getPricePerKg(final Price price) {
    if (price.product == null) {
      return null;
    }
    if (price.product!.quantityUnit != 'g') {
      return null;
    }
    return price.price / (price.product!.quantity! / 1000);
  }

  static String? _getLocationTitle(final Location? location) {
    if (location == null) {
      return null;
    }
    final StringBuffer result = StringBuffer();
    final String? countryEmoji = EmojiHelper().getCountryEmoji(
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
}
