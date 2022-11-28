import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class ProductImageCarousel extends StatelessWidget {
  /// Carousel of product images, or of just an [alternateImageUrl].
  const ProductImageCarousel(
    this.product, {
    required this.height,
    this.controller,
    this.onUpload,
    this.alternateImageUrl,
  });

  final Product product;
  final double height;
  final ScrollController? controller;
  final Function(BuildContext)? onUpload;
  final String? alternateImageUrl;

  @override
  Widget build(BuildContext context) {
    final List<ProductImageData> productImagesData;
    if (alternateImageUrl != null) {
      productImagesData = <ProductImageData>[
        ProductImageData(
          imageUrl: alternateImageUrl,
          imageField: ImageField.OTHER,
        ),
      ];
    } else {
      productImagesData = getProductMainImagesData(product);
    }
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
            child: ImageUploadCard(
              product: product,
              productImageData: data,
            ),
          );
        },
      ),
    );
  }
}
