import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/smooth_category.dart';

class CategoryQuery {
  static String getCurrentLanguageCode(final BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String getCurrentCountryCode(final BuildContext context) => Localizations.localeOf(context).countryCode ?? '';

  static List<TaxonomyCategoryField> get fields => TaxonomyCategoryField.values;

  void clearCache() {
    _cache.clear();
  }

  final Map<String, CategoryTreeNode> _cache = <String, CategoryTreeNode>{};

  Future<CategoryTreeNode?> getCategoryTreeRoot() async {
    final TaxonomyCategoryQueryConfiguration queryConfiguration =
        TaxonomyCategoryQueryConfiguration.roots(fields: fields, includeChildren: false);
    final Map<String, TaxonomyCategory>? tree =
        await OpenFoodAPIClient.getTaxonomyCategories(queryConfiguration);
    if (tree == null) {
      debugPrint('Unable to get tree for ${queryConfiguration.runtimeType}');
      return null;
    }
    debugPrint('Received tree for ${queryConfiguration.runtimeType}: $tree');
    final TaxonomyCategory root = TaxonomyCategory.fromJson(<String, dynamic>{
      'name': <String, String>{ OpenFoodFactsLanguage.ENGLISH.code: 'Root' },
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

  Future<Iterable<CategoryTreeNode>?> getCategories(Iterable<String> tags) async {
    final TaxonomyCategoryQueryConfiguration queryConfiguration =
        TaxonomyCategoryQueryConfiguration(tags: tags.toList(), fields: fields);
    final Map<String, TaxonomyCategory>? result =
        await OpenFoodAPIClient.getTaxonomyCategories(queryConfiguration);
    if (result == null) {
      return null;
    }
    return result.keys.map<CategoryTreeNode>((String key) {
      return CategoryTreeNode(Category(key, result[key]!));
    });
  }
}
