import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';

/// Displays a meta product with an action button, as a ListTile.
class PriceProductListTile extends StatelessWidget {
  const PriceProductListTile({
    required this.product,
    this.trailing,
  });

  final PriceMetaProduct product;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double size = screenSize.width * 0.20;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: size,
          child: product.getImageWidget(size),
        ),
        const SizedBox(width: SMALL_SPACE),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.getName(appLocalizations)),
              if (product.barcode.isNotEmpty) Text(product.barcode),
              if (product.originNames.isNotEmpty)
                Text(product.originNames.join(', ')),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
