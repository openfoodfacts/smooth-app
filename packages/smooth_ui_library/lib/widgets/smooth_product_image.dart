import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';

class SmoothProductImage extends StatelessWidget {
  const SmoothProductImage({@required this.product, this.width, this.height});

  final Product product;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (product.imgSmallUrl != null) {
      return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  product.imgSmallUrl,
                  scale: 1.0,
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Image.network(
                product.imgSmallUrl,
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
          ));
    } else {
      return Container(
        width: 100.0,
        height: 120.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          border: Border.all(color: Colors.white60, width: 1.0),
        ),
        child: Center(
            child: SvgPicture.asset(
          'assets/product/missing_image.svg',
          color: Colors.white60,
          width: 36.0,
          height: 36.0,
        )),
      );
    }
  }
}
