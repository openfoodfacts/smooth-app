import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image_container.dart';

/// Main product image on a product card.
class SmoothProductImage extends StatelessWidget {
  const SmoothProductImage({
    required this.product,
    required this.height,
    required this.width,
  });

  final Product product;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Widget child = _buildFromUrl(product.imageFrontSmallUrl) ??
        _buildFromUrl(product.imageFrontUrl) ??
        const Center(child: PictureNotFound());

    return SmoothProductImageContainer(
      width: width,
      height: height,
      child: child,
    );
  }

  Image? _buildFromUrl(final String? url) => url == null || url.isEmpty
      ? null
      : Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: _loadingBuilder,
        );

  Widget _loadingBuilder(
      BuildContext _, Widget child, ImageChunkEvent? progress) {
    if (progress == null) {
      return child;
    }

    final double progressValue =
        progress.cumulativeBytesLoaded / progress.expectedTotalBytes!;

    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: const AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
        value: progressValue,
      ),
    );
  }
}
