import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/smooth_matched_product.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
    required this.product,
    required this.heroTag,
    this.elevation = 0.0,
    this.backgroundColor,
    this.handle,
    this.onLongPress,
    this.refresh,
    this.onTap,
  });

  final Product product;
  final String heroTag;
  final double elevation;
  final Color? backgroundColor;
  final Widget? handle;
  final VoidCallback? onLongPress;
  final VoidCallback? refresh;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.of(context).size;

    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    final List<Widget> scores = <Widget>[];
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final List<Attribute> attributes = getPopulatedAttributes(
      product,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );
    for (final Attribute attribute in attributes) {
      scores.add(SvgIconChip(attribute.iconUrl!, height: iconSize));
    }
    final MatchedProduct matchedProduct = MatchedProduct.getMatchedProduct(
      product,
      productPreferences,
      userPreferences,
    );
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper(matchedProduct);
    return GestureDetector(
      onTap: onTap ??
          () async {
            await Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => ProductPage(product),
              ),
            );
            refresh?.call();
          },
      onLongPress: () {
        onLongPress?.call();
      },
      child: Hero(
        tag: heroTag,
        child: SmoothCard(
          elevation: elevation,
          color: backgroundColor,
          padding: const EdgeInsets.all(VERY_SMALL_SPACE),
          child: Row(
            children: <Widget>[
              SmoothProductImage(
                product: product,
                width: screenSize.width * 0.20,
                height: screenSize.width * 0.20,
              ),
              const Padding(padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
              Expanded(
                child: SizedBox(
                  height: screenSize.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getProductName(product, appLocalizations),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(
                        product.brands ?? appLocalizations.unknownBrand,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.circle,
                            size: 15,
                            color: helper.getBackgroundColor(),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
                          Text(
                            helper.getSubtitle(appLocalizations),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
              Padding(
                padding: const EdgeInsets.all(VERY_SMALL_SPACE),
                child: Column(
                  children: scores,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
