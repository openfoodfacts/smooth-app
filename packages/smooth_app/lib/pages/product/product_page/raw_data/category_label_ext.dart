import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

extension CategoryLabelExt on ProductRawDataCategories {
  String toL10nString(AppLocalizations appLocalizations) => switch (this) {
        ProductRawDataCategories.labels => appLocalizations.label_refresh,
        ProductRawDataCategories.category => appLocalizations.category,
        ProductRawDataCategories.ingredients => appLocalizations.ingredients,
        ProductRawDataCategories.countries =>
          appLocalizations.country_chooser_label_from_settings,
        ProductRawDataCategories.nutriment => appLocalizations.nutrition,
        ProductRawDataCategories.packaging =>
          appLocalizations.packaging_information,
        ProductRawDataCategories.stores =>
          appLocalizations.edit_product_form_item_stores_title,
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
