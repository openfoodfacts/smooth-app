import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/strike_through_text_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_per_extension.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Shows the price of a product, including the discount if applicable.
class PriceDataValue extends StatelessWidget {
  const PriceDataValue({required this.price});

  final Price price;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: ProductQuery.getLocaleString(),
      name: price.currency.name,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6.0,
          children: <Widget>[
            if (_hasDiscount(price)) ...<Widget>[
              _PriceDataContainer(
                value: _formatPrice(
                  currencyFormat,
                  price.priceWithoutDiscount!,
                  appLocalizations,
                ),
                backgroundColor: extension.primaryLight,
                textColor: extension.primaryBlack,
                strikeThroughColor: const Color(0x80341100),
              ),
              const icons.Arrow.right(size: 15.0),
            ],
            _PriceDataContainer(
              value: _formatPrice(
                currencyFormat,
                price.price,
                appLocalizations,
              ),
              backgroundColor: extension.primarySemiDark,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(
    final NumberFormat currencyFormat,
    final num value,
    final AppLocalizations appLocalizations,
  ) {
    final String formatted = currencyFormat.format(value);
    if (price.pricePer == null) {
      return formatted;
    }
    return '$formatted${price.pricePer!.getShortTitle(appLocalizations)}';
  }
}

bool _hasDiscount(Price price) {
  return price.priceIsDiscounted == true &&
      price.priceWithoutDiscount != null &&
      price.priceWithoutDiscount! > price.price;
}

class PriceDataDiscountedValue extends StatelessWidget {
  const PriceDataDiscountedValue({super.key, required this.price});

  final Price price;

  @override
  Widget build(BuildContext context) {
    if (!_hasDiscount(price)) {
      return EMPTY_WIDGET;
    }

    return _PriceDataContainer(
      value: NumberFormat('#0%').format(
        (price.price - price.priceWithoutDiscount!) /
            price.priceWithoutDiscount!,
      ),
      backgroundColor: context
          .extension<SmoothColorsThemeExtension>()
          .secondaryVibrant,
      textColor: Colors.white,
    );
  }
}

class _PriceDataContainer extends StatelessWidget {
  const _PriceDataContainer({
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    this.strikeThroughColor,
  });

  final String value;
  final Color backgroundColor;
  final Color textColor;
  final Color? strikeThroughColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: ANGULAR_BORDER_RADIUS,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: BALANCED_SPACE,
          end: BALANCED_SPACE,
          top: 3.0,
          bottom: VERY_SMALL_SPACE,
        ),
        child: StrikeThroughText(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          strikeThroughType: strikeThroughColor != null
              ? StrikeThroughTextType.horizontal
              : StrikeThroughTextType.none,
          strikeThroughThickness: 1.5,
          strikeThroughColor: strikeThroughColor,
        ),
      ),
    );
  }
}
