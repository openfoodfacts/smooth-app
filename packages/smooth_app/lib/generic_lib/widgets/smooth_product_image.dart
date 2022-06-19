import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/smooth_image.dart';

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
    Widget? result;
    result = _buildFromUrl(product.imageFrontSmallUrl);
    if (result != null) {
      return result;
    }
    result = _buildFromUrl(product.imageFrontUrl);
    if (result != null) {
      return result;
    }
    return ClipRRect(
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: FittedBox(
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          child: const Center(
            child: SmoothImage(
              'assets/product/product_not_found.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildFromUrl(final String? url) => url == null || url.isEmpty
      ? null
      : ClipRRect(
          borderRadius: ROUNDED_BORDER_RADIUS,
          child: SizedBox(
            width: width,
            height: height,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? progress) =>
                  progress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            value: progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!,
                          ),
                        ),
            ),
          ),
        );
}
