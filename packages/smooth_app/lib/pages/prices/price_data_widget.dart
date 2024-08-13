import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_proof_page.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Price Data display (no product data here).
class PriceDataWidget extends StatelessWidget {
  const PriceDataWidget(
    this.price, {
    required this.model,
  });

  final Price price;
  final GetPricesModel model;

  @override
  Widget build(BuildContext context) {
    final String locale = ProductQuery.getLocaleString();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat = DateFormat.yMd(locale);
    final DateFormat timeFormat = DateFormat.Hms(locale);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: price.currency.name,
    );
    final String? locationTitle = _getLocationTitle(price.location);

    String? getPricePerKg() {
      if (price.product == null) {
        return null;
      }
      if (price.product!.quantity == null) {
        return null;
      }
      if ((price.product!.quantityUnit ?? 'g') != 'g') {
        return null;
      }
      return '${currencyFormat.format(price.price / (price.product!.quantity! / 1000))} / kg';
    }

    String? getNotDiscountedPrice() {
      if (price.product == null) {
        return null;
      }
      if (price.priceIsDiscounted != true) {
        return null;
      }
      if (price.priceWithoutDiscount == null) {
        return null;
      }
      return '${appLocalizations.prices_amount_price_not_discounted} ${currencyFormat.format(price.priceWithoutDiscount)}';
    }

    final String? pricePerKg = getPricePerKg();
    final String? notDiscountedPrice = getNotDiscountedPrice();

    final String priceLabel = '${currencyFormat.format(price.price)}'
        ' ${pricePerKg == null ? '' : ' ($pricePerKg)'}';
    return Semantics(
      container: true,
      explicitChildNodes: false,
      label: appLocalizations.prices_entry_accessibility_label(
        priceLabel,
        locationTitle ?? '-',
        dateFormat.format(price.date),
        price.owner,
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          ExcludeSemantics(child: Text(priceLabel)),
          ExcludeSemantics(child: Text(dateFormat.format(price.date))),
          if (notDiscountedPrice != null) Text('($notDiscountedPrice)'),
          if (locationTitle != null)
            // TODO(monsieurtanuki): open a still-to-be-done "price x location" page
            ExcludeSemantics(
              child: PriceButton(
                title: locationTitle,
                iconData: Icons.location_on_outlined,
                onPressed: () {},
              ),
            ),
          if (model.displayOwner) PriceUserButton(price.owner),
          ExcludeSemantics(
            child: Tooltip(
              message: '${dateFormat.format(price.created)}'
                  ' '
                  '${timeFormat.format(price.created)}',
              child: PriceButton(
                // TODO(monsieurtanuki): misleading "active" button
                onPressed: () {},
                iconData: Icons.history,
                title: ProductQueryPageHelper.getDurationStringFromTimestamp(
                  price.created.millisecondsSinceEpoch,
                  context,
                  compact: true,
                ),
              ),
            ),
          ),
          if (price.proof?.filePath != null)
            PriceButton(
              iconData: Icons.image,
              tooltip: appLocalizations.prices_open_proof,
              onPressed: () async => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => PriceProofPage(
                    price.proof!,
                  ),
                ),
              ), // PriceProofPage
            ),
        ],
      ),
    );
  }

  static String? _getLocationTitle(final Location? location) {
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
}
