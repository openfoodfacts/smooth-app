import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/data_models/smooth_category.dart';

class CategoryQuery {
  static String getCurrentLanguageCode(final BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String getCurrentCountryCode() => window.locale.countryCode ?? '';

  static const User SMOOTH_USER = User(
    userId: 'project-smoothie',
    password: 'smoothie',
    comment: 'Test user for project smoothie',
  );

  static List<TaxonomyCategoryField> get fields => TaxonomyCategoryField.values;

  Future<CategoryTreeNode?> getCategoryTreeRoot() async {
    final TaxonomyCategoryQueryConfiguration queryConfiguration =
        TaxonomyCategoryQueryConfiguration.roots(fields: fields);
    final Map<String, TaxonomyCategory>? tree =
        await OpenFoodAPIClient.getTaxonomyCategories(queryConfiguration);
    if (tree == null) {
      debugPrint('Unable to get tree for ${queryConfiguration.runtimeType}');
      return null;
    }

    final TaxonomyCategory root = TaxonomyCategory.fromJson(<String, dynamic>{
      'name': <String, String>{ OpenFoodFactsLanguage.ENGLISH.code: 'root' },
      'children': tree.keys.toList(),
    });
    return CategoryTreeNode(Category('en:root', root));
  }

  Future<CategoryTreeNode?> getCategory(String tag) async {
    final TaxonomyCategoryQueryConfiguration queryConfiguration =
        TaxonomyCategoryQueryConfiguration(tags: <String>[tag], fields: fields);
    final Map<String, TaxonomyCategory>? result =
        await OpenFoodAPIClient.getTaxonomyCategories(queryConfiguration);
    if (result == null || result[tag] == null) {
      return null;
    }
    return CategoryTreeNode(Category(tag, result[tag]!));
  }
}
