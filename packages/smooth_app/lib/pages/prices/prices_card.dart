import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Card that displays buttons related to prices.
class PricesCard extends StatelessWidget {
  const PricesCard(
    this.product, {
    required this.model,
    required this.refresher,
  });

  final Product product;
  final GetPricesModel model;
  final ProductPriceRefresher refresher;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
          child: _PricesCardViewButton(product, model, refresher),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
          child: InkWell(
            onTap: () async => ProductPriceAddPage.showProductPage(
              context: context,
              product: PriceMetaProduct.product(product),
              proofType: ProofType.priceTag,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  appLocalizations.prices_add_a_price,
                  style: const TextStyle(fontSize: 15.5),
                ),
                const icons.Add(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PricesCardViewButton extends StatelessWidget {
  const _PricesCardViewButton(this.product, this.model, this.refresher);

  final Product product;
  final GetPricesModel model;
  final ProductPriceRefresher refresher;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return InkWell(
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              PricesPage(model, pricesResult: refresher.pricesResult),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            appLocalizations.prices_view_prices,
            style: const TextStyle(fontSize: 15.5),
          ),
          const icons.PriceTag(),
        ],
      ),
    );
  }
}
