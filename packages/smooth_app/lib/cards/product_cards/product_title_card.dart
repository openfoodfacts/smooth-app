import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(this.product, this.isSelectable, {this.dense = false});

  final Product product;
  final bool dense;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        dense: dense,
        contentPadding: EdgeInsets.zero,
        title: Text(
          _getProductName(appLocalizations),
          style: themeData.textTheme.headline4,
        ).selectable(isSelectable: isSelectable),
        subtitle: Text(product.brands ?? appLocalizations.unknownBrand),
        trailing: Text(
          product.quantity ?? '',
          style: themeData.textTheme.headline3,
        ).selectable(isSelectable: isSelectable),
      ),
    );
  }

  String _getProductName(final AppLocalizations appLocalizations) =>
      product.productName ?? appLocalizations.unknownProductName;
}
