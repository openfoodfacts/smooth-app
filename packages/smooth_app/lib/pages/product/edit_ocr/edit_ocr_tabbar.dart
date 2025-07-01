import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/edit_language_tabbar.dart';

class EditOcrTabBar extends StatelessWidget implements PreferredSizeWidget {
  const EditOcrTabBar({
    required this.onTabChanged,
    required this.imageField,
    required this.languagesWithText,
    super.key,
  });

  final void Function(OpenFoodFactsLanguage) onTabChanged;
  final ImageField imageField;
  final List<OpenFoodFactsLanguage> languagesWithText;

  @override
  Widget build(BuildContext context) {
    return EditLanguageTabBar(
      onTabChanged: onTabChanged,
      productEquality: productEquality,
      productLanguages: productLanguages,
      forceUserLanguage: false,
    );
  }

  List<ProductLanguageWithState> productLanguages(Product product) {
    return getProductImageLanguages(product, imageField)
        .map(
          (OpenFoodFactsLanguage l) => ProductLanguageWithState(
            language: l,
            state: languagesWithText.contains(l)
                ? OpenFoodFactsLanguageState.normal
                : OpenFoodFactsLanguageState.warning,
          ),
        )
        .toList(growable: false);
  }

  bool productEquality(Product oldProduct, Product product) {
    return product.barcode == oldProduct.barcode &&
        product.productType == oldProduct.productType &&
        product.imageIngredientsUrl == oldProduct.imageIngredientsUrl &&
        product.imageIngredientsSmallUrl == oldProduct.imageIngredientsSmallUrl;
  }

  @override
  Size get preferredSize => EditLanguageTabBar.PREFERRED_SIZE;
}
