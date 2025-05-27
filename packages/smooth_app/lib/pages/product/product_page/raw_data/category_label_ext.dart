import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

extension CategoryLabelExt on ProductRawDataCategories {
  String toL10nString(AppLocalizations appLocalizations) => switch (this) {
        ProductRawDataCategories.labels => appLocalizations.raw_data_category_labels,
        ProductRawDataCategories.category => appLocalizations.raw_data_category_categories,
        ProductRawDataCategories.ingredients => appLocalizations.raw_data_category_ingredients,
        ProductRawDataCategories.countries =>
          appLocalizations.raw_data_category_countries,
        ProductRawDataCategories.nutriment => appLocalizations.raw_data_category_nutrition,
        ProductRawDataCategories.packaging =>
          appLocalizations.raw_data_category_packages,
        ProductRawDataCategories.stores =>
          appLocalizations.raw_data_category_stores,
      };

  Widget toIcon() => switch (this) {
        ProductRawDataCategories.labels => const icons.Labels(),
        ProductRawDataCategories.category => const icons.Categories(),
        ProductRawDataCategories.ingredients => const icons.Ingredients(),
        ProductRawDataCategories.countries => const icons.Countries(),
        ProductRawDataCategories.nutriment => const icons.NutritionFacts(),
        ProductRawDataCategories.packaging => const icons.Packaging(),
        ProductRawDataCategories.stores => const icons.Stores(),
      };
}
