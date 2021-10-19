import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/svg_icon_chip.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/product/product_page.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
    required this.product,
    required this.heroTag,
    this.elevation = 0.0,
    this.useNewStyle = true,
    this.backgroundColor,
    this.handle,
    this.onLongPress,
    this.refresh,
  });

  final Product product;
  final String heroTag;
  final double elevation;
  final bool useNewStyle;
  final Color? backgroundColor;
  final Widget? handle;
  final VoidCallback? onLongPress;
  final VoidCallback? refresh;

  @override
  Widget build(BuildContext context) {
    if (!useNewStyle) {
      return _getOldStyle(context);
    }

    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    final List<String> attributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> scores = <Widget>[];
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final List<Attribute> attributes =
        AttributeListExpandable.getPopulatedAttributes(product, attributeIds);
    for (final Attribute attribute in attributes) {
      scores.add(SvgIconChip(attribute.iconUrl!, height: iconSize));
    }
    String productTitle;
    if (product.productName != null) {
      productTitle = product.productName!;
      if (product.brands != null) {
        productTitle += ' - ${product.brands!}';
      }
    } else if (product.brands != null) {
      productTitle = product.brands!;
    } else {
      productTitle = product.barcode!;
    }
    return GestureDetector(
      onTap: () async {
        await Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => ProductPage(product: product),
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
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SmoothProductImage(
                      product: product,
                      width: screenSize.width * 0.20,
                      height: screenSize.width * 0.20),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: screenSize.width * 0.65,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    productTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                if (handle != null) handle!,
                              ],
                            ),
                            SizedBox(
                              width: screenSize.width * 0.65,
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: scores,
                                spacing: 2.0,
                                runSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getOldStyle(final BuildContext context) => GestureDetector(
        onTap: () {
          //_openSneakPeek(context);
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ProductPage(
                product: product,
              ),
            ),
          );
        },
        child: Hero(
          tag: heroTag,
          child: Material(
            elevation: elevation,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SmoothProductImage(
                        product: product,
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10.0),
                        padding: const EdgeInsets.only(top: 7.5),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 140.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    product.productName ?? 'Unknown',
                                    maxLines: 3,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Flexible(
                                  child: Text(
                                    product.brands ??
                                        AppLocalizations.of(context)!
                                            .unknownBrand,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SizedBox(
                                  width: 100.0,
                                  child: product.nutriscore != null
                                      ? SvgPicture.network(
                                          'https://static.openfoodfacts.org/images/misc/nutriscore-${product.nutriscore}.svg',
                                          fit: BoxFit.contain,
                                        )
                                      : Center(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .nutri_score_unavailable,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
