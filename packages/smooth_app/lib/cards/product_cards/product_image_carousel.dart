import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class ProductImageCarousel extends StatelessWidget {
  const ProductImageCarousel(
    this.product, {
    required this.height,
    required this.onUpload,
  });

  final Product product;
  final double height;
  final Function(BuildContext) onUpload;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<ProductImageData> allProductImagesData =
        getAllProductImagesData(product, appLocalizations);

    return SizedBox(
      height: height,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: allProductImagesData
            .map(
              (ProductImageData item) => Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: const BoxDecoration(color: Colors.black12),
                child: ImageUploadCard(
                  product: product,
                  productImageData: item,
                  allProductImagesData: allProductImagesData,
                  onUpload: onUpload,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
