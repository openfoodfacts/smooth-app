import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/edit_language_tabbar.dart';

class ProductImageGalleryTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProductImageGalleryTabBar({required this.onTabChanged});

  final void Function(OpenFoodFactsLanguage) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return EditLanguageTabBar.noIndicator(
      onTabChanged: onTabChanged,
      productEquality: productEquality,
      productLanguages: productLanguages,
      forceUserLanguage: true,
    );
  }

  List<ProductLanguageWithState> productLanguages(Product product) {
    return <OpenFoodFactsLanguage>{
          ...getProductImageLanguages(product, ImageField.FRONT),
          ...getProductImageLanguages(product, ImageField.INGREDIENTS),
          ...getProductImageLanguages(product, ImageField.NUTRITION),
          ...getProductImageLanguages(product, ImageField.PACKAGING),
        }
        .map(
          (OpenFoodFactsLanguage l) =>
              ProductLanguageWithState.normal(language: l),
        )
        .toList(growable: false);
  }

  bool productEquality(Product oldProduct, Product product) {
    return product.barcode == oldProduct.barcode &&
        product.productType == oldProduct.productType &&
        product.imageFrontUrl == oldProduct.imageFrontUrl &&
        product.imageFrontSmallUrl == oldProduct.imageFrontSmallUrl &&
        product.imageIngredientsUrl == oldProduct.imageIngredientsUrl &&
        product.imageIngredientsSmallUrl ==
            oldProduct.imageIngredientsSmallUrl &&
        product.imageNutritionUrl == oldProduct.imageNutritionUrl &&
        product.imageNutritionSmallUrl == oldProduct.imageNutritionSmallUrl &&
        product.imagePackagingUrl == oldProduct.imagePackagingUrl &&
        product.imagePackagingSmallUrl == oldProduct.imagePackagingSmallUrl &&
        const ListEquality<ProductImage>().equals(
          product.selectedImages,
          oldProduct.selectedImages,
        ) &&
        const ListEquality<ProductImage>().equals(
          product.images,
          oldProduct.images,
        ) &&
        product.lastImage == oldProduct.lastImage &&
        const ListEquality<String>().equals(
          product.lastImageDates,
          oldProduct.lastImageDates,
        );
  }

  @override
  Size get preferredSize => EditLanguageTabBar.PREFERRED_SIZE;
}
