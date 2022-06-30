import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';

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
        onPressed: () async {
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          final OrderedNutrientsCache? cache =
              await OrderedNutrientsCache.getCache(context);
          if (cache == null) {
            return;
          }
          if (!mounted) {
            return;
          }
          await Navigator.push<Product>(
            context,
            MaterialPageRoute<Product>(
              builder: (BuildContext context) => NutritionPageLoaded(
                widget.product,
                cache.orderedNutrients,
              ),
            ),
          );
        },
      );
}
