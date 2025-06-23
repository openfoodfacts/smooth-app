import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page_loader.dart';

/// "Add nutrition facts" button for user contribution.
class AddNutritionButton extends StatelessWidget {
  const AddNutritionButton(this.product);

  final Product product;

  static bool acceptsNutritionFacts(final Product product) =>
      product.productType != ProductType.product &&
      product.productType != ProductType.beauty;

  @override
  Widget build(BuildContext context) => addPanelButton(
        AppLocalizations.of(context).score_add_missing_nutrition_facts,
        onPressed: () async => NutritionPageLoader.showNutritionPage(
          product: product,
          isLoggedInMandatory: true,
          context: context,
        ),
      );
}
