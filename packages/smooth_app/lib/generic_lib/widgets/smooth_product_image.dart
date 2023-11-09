import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/query/product_query.dart';

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
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    ImageProvider? imageProvider = TransientFile.fromProduct(
      product,
      ImageField.FRONT,
      language,
    ).getImageProvider();
    // if we couldn't find an image for that specific language, use the default.
    if (imageProvider == null) {
      final String? url = product.imageFrontUrl;
      if (url != null) {
        imageProvider = NetworkImage(url);
      }
    }

    return SmoothImage(
      width: width,
      height: height,
      imageProvider: imageProvider,
    );
  }
}
