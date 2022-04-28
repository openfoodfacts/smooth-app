import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(this.product, this.isSelectable, {this.dense = false});

  final Product product;
  final bool dense;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    Widget subtitle;
    Widget trailingWidget;
    if (!isSelectable) {
      final ContinuousScanModel model = context.watch<ContinuousScanModel>();
      subtitle = RichText(
        text: TextSpan(children: <InlineSpan>[
          TextSpan(
            text: product.brands ?? appLocalizations.unknownBrand,
          ),
          const TextSpan(text: ' , '),
          TextSpan(
            text: product.quantity ?? '',
            style: themeData.textTheme.headline3,
          ),
        ]),
      );
      trailingWidget = InkWell(
        onTap: () {
          model.removeBarcode(product.barcode!);
        },
        child: const Icon(Icons.clear_rounded),
      );
    } else {
      subtitle = Text(product.brands ?? appLocalizations.unknownBrand);
      trailingWidget = Text(
        product.quantity ?? '',
        style: themeData.textTheme.headline3,
      ).selectable(isSelectable: isSelectable);
    }
    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        dense: dense,
        contentPadding: EdgeInsets.zero,
        title: Text(
          getProductName(product, appLocalizations),
          style: themeData.textTheme.headline4,
        ).selectable(isSelectable: isSelectable),
        subtitle: subtitle,
        trailing: trailingWidget,
      ),
    );
  }
}
