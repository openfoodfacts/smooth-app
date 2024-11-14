import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(
    this.product,
    this.isSelectable, {
    this.dense = false,
    this.isRemovable = true,
    this.onRemove,
  });

  final Product product;
  final bool dense;
  final bool isSelectable;
  final bool isRemovable;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final Widget trailing = _ProductTitleCardTrailing(
      removable: isRemovable,
      selectable: isSelectable,
      onRemove: onRemove,
    );

    final List<Widget> children;

    if (dense) {
      children = <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _ProductTitleCardName(
                selectable: isSelectable,
                dense: dense,
              ),
            ),
            trailing,
          ],
        ),
        _ProductTitleCardBrand(
          removable: isRemovable,
          selectable: isSelectable,
        ),
      ];
    } else {
      final Size imageSize =
          Size.square(MediaQuery.sizeOf(context).width * 0.25);

      children = <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TooltipTheme(
                  data: TooltipThemeData(
                    verticalOffset: imageSize.width / 2,
                    preferBelow: true,
                  ),
                  child: ProductPicture(
                    product: product,
                    imageField: ImageField.FRONT,
                    fallbackUrl: product.imageFrontUrl,
                    size: imageSize,
                    showObsoleteIcon: true,
                    imageFoundBorder: 1.0,
                    imageNotFoundBorder: 1.0,
                    borderRadius: BorderRadius.circular(14.0),
                    onTap: () async => Navigator.push<void>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (BuildContext context) =>
                            ProductImageGalleryView(
                          product: product,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SMALL_SPACE,
                      top: VERY_SMALL_SPACE,
                      bottom: VERY_SMALL_SPACE,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                DefaultTextStyle.of(context).style.fontSize! *
                                    2.0,
                          ),
                          child: _ProductTitleCardName(
                            selectable: isSelectable,
                            dense: dense,
                          ),
                        ),
                        const SizedBox(height: SMALL_SPACE),
                        _ProductTitleCardBrand(
                          removable: isRemovable,
                          selectable: isSelectable,
                        ),
                        const SizedBox(height: 2.0),
                        trailing,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return Provider<Product>.value(
      value: product,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ProductTitleCardName extends StatelessWidget {
  const _ProductTitleCardName({
    required this.selectable,
    this.dense = false,
  });

  final bool dense;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return Text(
      getProductName(product, appLocalizations),
      style: dense ? textStyle : textStyle?.copyWith(fontSize: 18.0),
      textAlign: TextAlign.start,
      maxLines: dense ? 2 : null,
      overflow: TextOverflow.ellipsis,
    ).selectable(isSelectable: selectable);
  }
}

class _ProductTitleCardBrand extends StatelessWidget {
  const _ProductTitleCardBrand({
    required this.selectable,
    required this.removable,
  });

  final bool selectable;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final String brands = getProductBrands(product, appLocalizations);
    final String quantity = product.quantity ?? '';

    final String subtitleText;

    if (removable && !selectable) {
      subtitleText = '$brands${quantity == '' ? '' : ', $quantity'}';
    } else {
      subtitleText = brands;
    }

    return Text(
      subtitleText,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.start,
    ).selectable(isSelectable: selectable);
  }
}

class _ProductTitleCardTrailing extends StatelessWidget {
  const _ProductTitleCardTrailing({
    required this.selectable,
    required this.removable,
    required this.onRemove,
  });

  final bool selectable;
  final bool removable;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    if (removable && !selectable) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ProductCardCloseButton(
          onRemove: onRemove,
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
        ),
      );
    } else {
      return Text(
        product.quantity ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.end,
      ).selectable(isSelectable: selectable);
    }
  }
}
