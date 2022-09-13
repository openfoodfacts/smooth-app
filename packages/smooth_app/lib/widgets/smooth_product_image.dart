import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';

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
    final NetworkImage? child = _buildFromUrl(product.imageFrontSmallUrl) ??
        _buildFromUrl(product.imageFrontUrl);

    return SmoothImage(
      width: width,
      height: height,
      imageProvider: child,
    );
  }

  NetworkImage? _buildFromUrl(final String? url) =>
      url == null || url.isEmpty ? null : NetworkImage(url);
}
