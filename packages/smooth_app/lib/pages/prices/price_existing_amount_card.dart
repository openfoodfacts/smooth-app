import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_existing_amount_field.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';

/// Card that displays an existing amount.
class PriceExistingAmountCard extends StatelessWidget {
  const PriceExistingAmountCard(
    this.price,
  );

  final Price price;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDiscounted = price.priceIsDiscounted ?? false;
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_amount_subtitle,
      leading: const Icon(Icons.history),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: SMALL_SPACE,
      ),
      child: Column(
        children: <Widget>[
          if (price.product != null)
            PriceProductListTile(
              product: PriceMetaProduct.priceProduct(price.product!),
            ),
          SwitchListTile(
            value: isDiscounted,
            onChanged: null,
            title: Text(appLocalizations.prices_amount_is_discounted),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            children: <Widget>[
              Expanded(
                child: PriceExistingAmountField(
                  value: price.price,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !isDiscounted
                    ? Container()
                    : PriceExistingAmountField(
                        value: price.priceWithoutDiscount,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
