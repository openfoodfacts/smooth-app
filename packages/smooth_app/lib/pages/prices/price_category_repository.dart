import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/price_taxonomy_repository.dart';

/// Helper for "Category" tag localization.
class PriceCategoryRepository
    extends PriceTaxonomyRepository<TaxonomyCategory> {
  static final Map<String, String> _cachedMap = <String, String>{};

  @protected
  @override
  Map<String, String> getCachedMap() => _cachedMap;

  @protected
  @override
  Map<OpenFoodFactsLanguage, String>? getTaxonomyNames(
    final TaxonomyCategory item,
  ) => item.name;

  @protected
  @override
  Future<Map<String, TaxonomyCategory>?> download(
    final List<String> tags,
  ) async => OpenFoodAPIClient.getTaxonomyCategories(
    TaxonomyCategoryQueryConfiguration(
      tags: tags,
      country: getCountry(),
      languages: <OpenFoodFactsLanguage>[getLanguage()],
      fields: <TaxonomyCategoryField>[TaxonomyCategoryField.NAME],
      includeChildren: false,
    ),
  );
}
