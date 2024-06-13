import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';

/// Displays a meta product with an action button, as a ListTile.
class PriceProductListTile extends StatelessWidget {
  const PriceProductListTile({
    required this.product,
    required this.trailingIconData,
    required this.onPressed,
  });

  final PriceMetaProduct product;
  final IconData trailingIconData;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double size = screenSize.width * 0.20;
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            child: product.product != null
                ? SmoothMainProductImage(
                    product: product.product!,
                    width: size,
                    height: size,
                  )
                : SmoothImage(
                    width: size,
                    height: size,
                    imageProvider: product.imageUrl == null
                        ? null
                        : NetworkImage(product.imageUrl!),
                  ),
          ),
          const SizedBox(width: SMALL_SPACE),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(product.getName(appLocalizations)),
                Text(product.barcode),
              ],
            ),
          ),
          Icon(trailingIconData),
        ],
      ),
    );
  }
}
