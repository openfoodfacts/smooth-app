import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';

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
    return Provider<Product>.value(
      value: product,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: InkWell(
          onTap: _hasProductName
              ? () async {
                  await Navigator.push<Product?>(
                    context,
                    MaterialPageRoute<Product>(
                      builder: (BuildContext context) =>
                          AddBasicDetailsPage(product),
                    ),
                  );
                }
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _ProductTitleCardName(
                      selectable: isSelectable,
                    ),
                  ),
                  Expanded(
                    child: _ProductTitleCardTrailing(
                      removable: isRemovable,
                      selectable: isSelectable,
                      onRemove: onRemove,
                    ),
                  )
                ],
              ),
              _ProductTitleCardBrand(
                removable: isRemovable,
                selectable: isSelectable,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasProductName => product.productName != null;
}

class _ProductTitleCardName extends StatelessWidget {
  const _ProductTitleCardName({
    required this.selectable,
  });

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    return Text(
      getProductName(product, appLocalizations),
      style: Theme.of(context).textTheme.headline4,
      textAlign: TextAlign.start,
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
      style: Theme.of(context).textTheme.bodyText2,
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
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onRemove?.call(context),
          child: Tooltip(
            message: appLocalizations.product_card_remove_product_tooltip,
            child: const Padding(
              padding: EdgeInsets.all(SMALL_SPACE),
              child: Icon(
                Icons.clear_rounded,
                size: DEFAULT_ICON_SIZE,
              ),
            ),
          ),
        ),
      );
    } else {
      return Text(
        product.quantity ?? '',
        style: Theme.of(context).textTheme.headline3,
        textAlign: TextAlign.end,
      ).selectable(isSelectable: selectable);
    }
  }
}

typedef OnRemoveCallback = void Function(BuildContext context);
