import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/svg_icon_chip.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
    required this.product,
    required this.heroTag,
    this.elevation = 0.0,
    this.backgroundColor,
    this.handle,
    this.onLongPress,
    this.refresh,
  });

  final Product product;
  final String heroTag;
  final double elevation;
  final Color? backgroundColor;
  final Widget? handle;
  final VoidCallback? onLongPress;
  final VoidCallback? refresh;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    final List<Widget> scores = <Widget>[];
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final List<Attribute> attributes =
        getPopulatedAttributes(product, SCORE_ATTRIBUTE_IDS);
    for (final Attribute attribute in attributes) {
      scores.add(SvgIconChip(attribute.iconUrl!, height: iconSize));
    }
    final ProductCompatibilityResult compatibility =
        getProductCompatibility(context.watch<ProductPreferences>(), product);
    return GestureDetector(
      onTap: () async {
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
        child: Material(
          elevation: elevation,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? themeData.colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            ),
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
                          product.productName ?? '???',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Text(
                          product.brands ?? '???',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              size: 15,
                              color:
                                  getProductCompatibilityHeaderBackgroundColor(
                                      compatibility.productCompatibility),
                            ),
                            const Padding(
                                padding:
                                    EdgeInsets.only(left: VERY_SMALL_SPACE)),
                            Text(
                              getSubtitle(compatibility, appLocalizations),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: VERY_SMALL_SPACE)),
                Column(
                  children: scores,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
