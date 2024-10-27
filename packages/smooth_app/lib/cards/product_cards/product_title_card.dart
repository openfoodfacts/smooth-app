import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

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
    final Widget title = _ProductTitleCardTrailing(
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
            title,
          ],
        ),
        _ProductTitleCardBrand(
          removable: isRemovable,
          selectable: isSelectable,
        ),
      ];
    } else {
      children = <Widget>[
        _ProductTitleCardName(
          selectable: isSelectable,
          dense: dense,
        ),
        _ProductTitleCardBrand(
          removable: isRemovable,
          selectable: isSelectable,
        ),
        title,
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
    final Product product = context.read<Product>();

    return Text(
      getProductName(product, appLocalizations),
      style: Theme.of(context).textTheme.headlineMedium,
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
    final Product product = context.read<Product>();

    final String brands = product.brands ?? appLocalizations.unknownBrand;
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
    final Product product = context.read<Product>();

    if (removable && !selectable) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ProductCardCloseButton(
          onRemove: onRemove,
        ),
      );
    } else {
      return Text(
        product.quantity ?? '',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.end,
      ).selectable(isSelectable: selectable);
    }
  }
}
