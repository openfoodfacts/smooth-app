import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/data_cards/product_image_carousel_item.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Carousel of product images.
class ProductImageCarousel extends StatelessWidget {
  const ProductImageCarousel(
    this.product, {
    required this.height,
    this.controller,
  });

  final Product product;
  final double height;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final List<ProductImageData> productImagesData = getProductMainImagesData(
      product,
      ProductQuery.getLanguage(),
      includeOther: true,
    );
    return SizedBox(
      height: height,
      child: ListView.builder(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: productImagesData.length,
        itemBuilder: (_, int index) {
          final ProductImageData data = productImagesData[index];
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            decoration: const BoxDecoration(color: Colors.black12),
            child: ProductImageCarouselItem(
              product: product,
              productImageData: data,
            ),
          );
        },
      ),
    );
  }
}
