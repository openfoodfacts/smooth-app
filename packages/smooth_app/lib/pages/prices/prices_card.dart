import 'dart:math';

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
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Card that displays buttons related to prices.
class PricesCard extends StatelessWidget {
  const PricesCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return buildProductSmoothCard(
      title: Stack(
        children: <Widget>[
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: LARGE_SPACE,
            child: Container(
              decoration: BoxDecoration(
                color: themeExtension.orange,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsetsDirectional.only(
                top: 5.0,
                start: 6.0,
                end: 6.0,
                bottom: 7.0,
              ),
              child: const icons.Lab(
                size: 10.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: SMALL_SPACE),
          Center(child: Text(appLocalizations.prices_generic_title)),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Stack(
          children: <Widget>[
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 0.0,
              end: 0.0,
              child: const _PricesCardTitleIcon(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
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
          ],
        ),
      ),
      margin: const EdgeInsetsDirectional.only(
        start: SMALL_SPACE,
        end: SMALL_SPACE,
        top: VERY_LARGE_SPACE,
      ),
    );
  }
}

class _PricesCardTitleIcon extends StatelessWidget {
  const _PricesCardTitleIcon();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension? themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>();

    return Transform.rotate(
      angle: -pi / 6,
      child: icons.Lab(
        size: 100.0,
        color: themeExtension?.orange
            .withOpacity(context.lightTheme() ? 0.15 : 0.4),
      ),
    );
  }
}
