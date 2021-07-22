import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';

abstract class ProductQuery {
  static String getCurrentLanguageCode(final BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String getCurrentCountryCode() => window.locale.countryCode ?? '';

  static const User SMOOTH_USER = User(
    userId: 'project-smoothie',
    password: 'smoothie',
    comment: 'Test user for project smoothie',
  );

  static List<ProductField> get fields => <ProductField>[
        ProductField.NAME,
        ProductField.BRANDS,
        ProductField.BARCODE,
        ProductField.NUTRISCORE,
        ProductField.FRONT_IMAGE,
        ProductField.IMAGE_FRONT_SMALL_URL,
        ProductField.IMAGE_FRONT_URL,
        ProductField.IMAGE_INGREDIENTS_URL,
        ProductField.IMAGE_NUTRITION_URL,
        ProductField.IMAGE_PACKAGING_URL,
        ProductField.SELECTED_IMAGE,
        ProductField.QUANTITY,
        ProductField.SERVING_SIZE,
        ProductField.PACKAGING_QUANTITY,
        ProductField.NUTRIMENTS,
        ProductField.NUTRIENT_LEVELS,
        ProductField.NUTRIMENT_ENERGY_UNIT,
        ProductField.ADDITIVES,
        ProductField.INGREDIENTS_ANALYSIS_TAGS,
        ProductField.LABELS_TAGS,
        ProductField.LABELS_TAGS_IN_LANGUAGES,
        ProductField.ENVIRONMENT_IMPACT_LEVELS,
        ProductField.CATEGORIES_TAGS,
        ProductField.CATEGORIES_TAGS_IN_LANGUAGES,
        ProductField.LANGUAGE,
        ProductField.ATTRIBUTE_GROUPS,
      ];

  Future<SearchResult> getSearchResult();

  ProductList getProductList();
}
