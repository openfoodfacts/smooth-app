import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';

class SmoothProductImage extends StatelessWidget {
  const SmoothProductImage({
    @required this.product,
    this.maxHeight = 80.0,
    this.maxWidth = 80.0,
  });

  final Product product;
  final double maxHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    Widget result;
    result = _buildFromUrl(product.imageFrontSmallUrl);
    if (result != null) {
      return result;
    }
    result = _buildFromUrl(product.imageFrontUrl);
    if (result != null) {
      return result;
    }
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      child: FittedBox(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 1,
            minHeight: 1,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/product/product_not_found.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFromUrl(final String url) => url == null || url.isEmpty
      ? null
      : ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          child: FittedBox(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 1,
                minHeight: 1,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(url, scale: 1.0),
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent progress) =>
                        progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  value: progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes,
                                ),
                              ),
                  ),
                ),
              ),
            ),
          ),
        );
}
