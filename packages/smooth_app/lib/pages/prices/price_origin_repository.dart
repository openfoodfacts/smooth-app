import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/price_taxonomy_repository.dart';

/// Helper for "Origins" tag localization.
class PriceOriginRepository extends PriceTaxonomyRepository<TaxonomyOrigin> {
  static final Map<String, String> _cachedMap = <String, String>{};

  @protected
  @override
  Map<String, String> getCachedMap() => _cachedMap;

  @protected
  @override
  Map<OpenFoodFactsLanguage, String>? getTaxonomyNames(
    final TaxonomyOrigin item,
  ) => item.name;

  @protected
  @override
  Future<Map<String, TaxonomyOrigin>?> download(
    final List<String> tags,
  ) async => OpenFoodAPIClient.getTaxonomyOrigins(
    TaxonomyOriginQueryConfiguration(
      tags: tags,
      country: getCountry(),
      languages: <OpenFoodFactsLanguage>[getLanguage()],
      fields: <TaxonomyOriginField>[TaxonomyOriginField.NAME],
      includeChildren: false,
    ),
  );
}
