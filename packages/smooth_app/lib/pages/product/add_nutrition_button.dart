import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';

/// "Add nutrition facts" button for user contribution.
class AddNutritionButton extends StatefulWidget {
  const AddNutritionButton(this.product);

  final Product product;

  @override
  State<AddNutritionButton> createState() => _AddNutritionButtonState();
}

class _AddNutritionButtonState extends State<AddNutritionButton> {
  @override
  Widget build(BuildContext context) => addPanelButton(
        AppLocalizations.of(context).score_add_missing_nutrition_facts,
        onPressed: () async => NutritionPageLoaded.showNutritionPage(
          product: widget.product,
          isLoggedInMandatory: true,
          widget: this,
        ),
      );
}
