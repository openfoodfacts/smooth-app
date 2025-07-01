import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterAddPriceButton extends StatelessWidget {
  const ProductFooterAddPriceButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConsumerFilter<UserPreferences>(
      buildWhen: (UserPreferences? previous, UserPreferences current) =>
          previous?.userCurrencyCode != current.userCurrencyCode,
      builder: (BuildContext context, UserPreferences userPreferences, _) {
        final Currency currency = Currency.values.firstWhere(
          (Currency currency) =>
              currency.name == userPreferences.userCurrencyCode,
          orElse: () => Currency.USD,
        );

        return ProductFooterButton(
          label: appLocalizations.prices_add_a_price,
          icon: icons.AddPrice(currency),
          onTap: () => _addAPrice(context, context.read<Product>()),
        );
      },
    );
  }

  Future<void> _addAPrice(BuildContext context, Product product) {
    return ProductPriceAddPage.showProductPage(
      context: context,
      product: PriceMetaProduct.product(context.read<Product>()),
      proofType: ProofType.priceTag,
    );
  }
}
