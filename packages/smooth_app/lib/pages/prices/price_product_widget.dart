import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';

/// Price Product display (no price data here).
class PriceProductWidget extends StatelessWidget {
  const PriceProductWidget(this.priceProduct);

  final PriceProduct priceProduct;

  static const double _imageSize = 75;

  @override
  Widget build(BuildContext context) {
    final String? name = priceProduct.name;
    final String? imageURL = priceProduct.imageURL;
    final int priceCount = priceProduct.priceCount;
    final List<String>? brands = priceProduct.brands?.split(',');
    final String? quantity = priceProduct.quantity == null
        ? null
        : '${priceProduct.quantity} ${priceProduct.quantityUnit ?? 'g'}';
    return LayoutBuilder(
      builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) =>
          Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (imageURL != null)
            SizedBox(
              width: _imageSize,
              child: SmoothImage(
                width: _imageSize,
                height: _imageSize,
                imageProvider: NetworkImage(imageURL),
              ),
            ),
          if (imageURL != null) const SizedBox(width: SMALL_SPACE),
          SizedBox(
            width: imageURL == null
                ? constraints.maxWidth
                : constraints.maxWidth - _imageSize - SMALL_SPACE,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (name != null)
                  AutoSizeText(
                    name,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                Wrap(
                  spacing: VERY_SMALL_SPACE,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 0,
                  children: <Widget>[
                    PriceCountWidget(priceCount),
                    if (brands != null)
                      for (final String brand in brands)
                        PriceButton(
                          title: brand,
                          onPressed: () {},
                        ),
                    if (quantity != null) Text(quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
