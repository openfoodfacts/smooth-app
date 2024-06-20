import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Card that displays buttons related to prices.
class PricesCard extends StatelessWidget {
  const PricesCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension? themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>();

    return buildProductSmoothCard(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).prices_generic_title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(width: SMALL_SPACE),
                Container(
                  decoration: BoxDecoration(
                    color: themeExtension!.secondaryNormal,
                    borderRadius: CIRCULAR_BORDER_RADIUS,
                  ),
                  margin: const EdgeInsets.only(top: 0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: MEDIUM_SPACE,
                    vertical: VERY_SMALL_SPACE,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: SMALL_SPACE),
                      Lab(
                        color: Colors.white,
                        size: 13.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SMALL_SPACE),
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_view_prices,
                icon: CupertinoIcons.tag_fill,
                onPressed: () async => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => PricesPage(
                      GetPricesModel.product(
                        product: PriceMetaProduct.product(product),
                        context: context,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_add_a_price,
                icon: Icons.add,
                onPressed: () async => ProductPriceAddPage.showProductPage(
                  context: context,
                  product: PriceMetaProduct.product(product),
                  proofType: ProofType.priceTag,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
