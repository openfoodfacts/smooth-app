import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(this.product, {this.dense = false});

  final Product product;
  final bool dense;

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
        ),
        subtitle: Text(product.brands ?? appLocalizations.unknownBrand),
        trailing: Text(
          product.quantity ?? '',
          style: themeData.textTheme.headline3,
        ),
      ),
    );
  }

  String _getProductName(final AppLocalizations appLocalizations) =>
      product.productName ?? appLocalizations.unknownProductName;
}
