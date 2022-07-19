import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';
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
    Widget? result;
    result = _buildFromUrl(product.imageFrontSmallUrl);
    if (result != null) {
      return result;
    }
    result = _buildFromUrl(product.imageFrontUrl);
    if (result != null) {
      return result;
    }
    return SmoothProductImageContainer(
      width: width,
      height: height,
      child: Center(
        child: SvgPicture.asset(
          'assets/product/product_not_found.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget? _buildFromUrl(final String? url) => url == null || url.isEmpty
      ? null
      : SmoothProductImageContainer(
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
        );
}
