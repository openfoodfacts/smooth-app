import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
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
                color: themeExtension.secondaryVibrant,
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
                  child: _PricesCardViewButton(product),
                ),
                Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: SmoothLargeButtonWithIcon(
                    text: appLocalizations.prices_add_a_price,
                    leadingIcon: const Icon(Icons.add),
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
        color: themeExtension?.secondaryVibrant
            .withValues(alpha: context.lightTheme() ? 0.15 : 0.4),
      ),
    );
  }
}

class _PricesCardViewButton extends StatefulWidget {
  const _PricesCardViewButton(this.product);

  final Product product;

  @override
  State<_PricesCardViewButton> createState() => _PricesCardViewButtonState();
}

class _PricesCardViewButtonState extends State<_PricesCardViewButton> {
  GetPricesModel? _model;
  ProductPriceRefresher? _productPriceRefresher;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    _model ??= GetPricesModel.product(
      product: PriceMetaProduct.product(widget.product),
      context: context,
    );
    _productPriceRefresher ??= ProductPriceRefresher(
      model: _model!,
      userPreferences: context.read<UserPreferences>(),
      pricesResult: null,
      refreshDisplay: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    context.watch<LocalDatabase>();
    unawaited(_productPriceRefresher!.runIfNeeded());

    final int? total = _productPriceRefresher!.pricesResult?.total;
    return Badge(
      offset: Offset.zero,
      isLabelVisible: total != null,
      backgroundColor:
          context.extension<SmoothColorsThemeExtension>().secondaryNormal,
      label: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: VERY_SMALL_SPACE,
          end: VERY_SMALL_SPACE,
          top: VERY_SMALL_SPACE,
          bottom: 6.0,
        ),
        child: Text(
          '$total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SmoothLargeButtonWithIcon(
        text: appLocalizations.prices_view_prices,
        leadingIcon: const Icon(CupertinoIcons.tag_fill),
        onPressed: () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PricesPage(
              _model!,
              pricesResult: _productPriceRefresher!.pricesResult,
            ),
          ),
        ),
      ),
    );
  }
}
