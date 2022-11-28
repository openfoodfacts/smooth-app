import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Main product image on a product card.
class SmoothMainProductImage extends StatelessWidget {
  const SmoothMainProductImage({
    required this.product,
    required this.height,
    required this.width,
  });

  final Product product;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      getProductImageData(product, ImageField.FRONT),
      product.barcode!,
    );

    return SmoothImage(
      width: width,
      height: height,
      imageProvider: imageProvider,
    );
  }
}
