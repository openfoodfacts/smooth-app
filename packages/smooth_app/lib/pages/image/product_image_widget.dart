import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/query/product_query.dart';

/// Displays a product image thumbnail with the upload date on top.
class ProductImageWidget extends StatelessWidget {
  const ProductImageWidget({
    required this.productImage,
    required this.barcode,
    required this.squareSize,
  });

  final ProductImage productImage;
  final String barcode;
  final double squareSize;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final Widget image = SmoothImage(
      width: squareSize,
      height: squareSize,
      imageProvider: NetworkImage(
        productImage.getUrl(
          barcode,
          uriHelper: ProductQuery.uriProductHelper,
        ),
      ),
      rounded: false,
    );
    final DateTime? uploaded = productImage.uploaded;
    if (uploaded == null) {
      return image;
    }
    final DateTime now = DateTime.now();
    final String date = _dateFormat.format(uploaded);
    final bool expired = now.difference(uploaded).inDays > 365;
    return Stack(
      children: <Widget>[
        image,
        SizedBox(
          width: squareSize,
          height: squareSize,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: Container(
                height: VERY_LARGE_SPACE,
                color: expired
                    ? Colors.red.withAlpha(128)
                    : Colors.white.withAlpha(128),
                child: Center(
                  child: AutoSizeText(
                    date,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
