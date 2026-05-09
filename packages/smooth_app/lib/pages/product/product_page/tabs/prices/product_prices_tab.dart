import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/pages/product/product_page/tabs/prices/product_prices_counter.dart';
import 'package:smooth_app/pages/product/product_page/tabs/prices/product_prices_explainer.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_entry.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_title.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class ProductPricesTab extends StatelessWidget {
  const ProductPricesTab(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.zero,
      children: <Widget>[
        const ProductPricesExplanationBanner(),
        PricesCard(product),
      ],
    );
  }
}

class PricesCard extends StatelessWidget {
  const PricesCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ProductPageTitle(label: appLocalizations.prices_generic_title),
        _PricesCardViewButton(product),
        _PricesCardAddButton(product),
      ],
    );
  }
}

class _PricesCardAddButton extends StatelessWidget {
  const _PricesCardAddButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return ProductPageEntry(
      label: appLocalizations.prices_add_a_price,
      leading: const icons.Add(color: Colors.white),
      leadingColor: theme.secondaryLight,
      onTap: () async => ProductPriceAddPage.showProductPage(
        context: context,
        product: PriceMetaProduct.product(product),
        proofType: ProofType.priceTag,
      ),
    );
  }
}

class _PricesCardViewButton extends StatelessWidget {
  const _PricesCardViewButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return PricesCounter(
      product: product,
      builder:
          (
            GetPricesModel model,
            ProductPriceRefresher productPriceRefresher,
            int? total,
          ) => ProductPageEntry(
            label: appLocalizations.prices_view_prices,
            leading: const icons.PriceTag(color: Colors.white),
            leadingColor: theme.secondaryLight,
            trailing: total == null
                ? null
                : Container(
                    decoration: BoxDecoration(
                      color: theme.primaryNormal,
                      borderRadius: ANGULAR_BORDER_RADIUS,
                    ),
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: VERY_SMALL_SPACE,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SMALL_SPACE,
                      vertical: VERY_SMALL_SPACE,
                    ),
                    child: Text(
                      NumberFormat.decimalPattern(
                        ProductQuery.getLanguage().offTag,
                      ).format(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => PricesPage(
                  model,
                  pricesResult: productPriceRefresher.pricesResult,
                ),
              ),
            ),
          ),
    );
  }
}
