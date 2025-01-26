import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';

class NutritionPageLoader {
  const NutritionPageLoader._();

  /// Shows the nutrition page after loading the ordered nutrient list.
  static Future<void> showNutritionPage({
    required final Product product,
    required final bool isLoggedInMandatory,
    required final BuildContext context,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }
    if (context.mounted) {
      final OrderedNutrientsCache? cache =
          await OrderedNutrientsCache.getCache(context);
      if (context.mounted) {
        if (cache == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SmoothFloatingSnackbar.error(
              context: context,
              text: AppLocalizations.of(context).nutrition_cache_loading_error,
            ),
          );
          return;
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => NutritionPageLoaded(
              product,
              cache.orderedNutrients,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
          ),
        );
      }
    }
  }
}
