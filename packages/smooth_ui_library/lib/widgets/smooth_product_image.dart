import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';

class SmoothProductImage extends StatelessWidget {
  const SmoothProductImage({@required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.imageFrontSmallUrl != null &&
        product.imageFrontSmallUrl != '') {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        child: FittedBox(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  product.imageFrontSmallUrl,
                  scale: 1.0,
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Image.network(
                product.imageFrontSmallUrl,
                fit: BoxFit.contain,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent progress) {
                  if (progress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      value: progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        child: FittedBox(
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
      );
    }
  }
}
