import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Translations around products
class ProductTranslationHelper {
  ProductTranslationHelper(this.appLocalizations);

  final AppLocalizations appLocalizations;

  /// Translations for [ProductImprovement]s
  String getImprovementTranslation(final ProductImprovement improvement) {
    switch (improvement) {
      case ProductImprovement.ORIGINS_TO_BE_COMPLETED:
        return appLocalizations.product_improvement_origins_to_be_completed;
      case ProductImprovement.CATEGORIES_BUT_NO_NUTRISCORE:
        return appLocalizations
            .product_improvement_categories_but_no_nutriscore;
      case ProductImprovement.ADD_NUTRITION_FACTS:
        return appLocalizations.product_improvement_add_nutrition_facts;
      case ProductImprovement.ADD_CATEGORY:
        return appLocalizations.product_improvement_add_category;
      case ProductImprovement.ADD_NUTRITION_FACTS_AND_CATEGORY:
        return appLocalizations
            .product_improvement_add_nutrition_facts_and_category;
      case ProductImprovement.OBSOLETE_NUTRITION_IMAGE:
        return appLocalizations.product_improvement_obsolete_nutrition_image;
    }
  }
}
