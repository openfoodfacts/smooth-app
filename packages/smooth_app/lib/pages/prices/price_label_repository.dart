import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/price_taxonomy_repository.dart';

/// Helper for "Labels" tag localization.
class PriceLabelRepository extends PriceTaxonomyRepository<TaxonomyLabel> {
  static final Map<String, String> _cachedMap = <String, String>{};

  @protected
  @override
  Map<String, String> getCachedMap() => _cachedMap;

  @protected
  @override
  Map<OpenFoodFactsLanguage, String>? getTaxonomyNames(
    final TaxonomyLabel item,
  ) => item.name;

  @protected
  @override
  Future<Map<String, TaxonomyLabel>?> download(final List<String> tags) async =>
      OpenFoodAPIClient.getTaxonomyLabels(
        TaxonomyLabelQueryConfiguration(
          tags: tags,
          country: getCountry(),
          languages: <OpenFoodFactsLanguage>[getLanguage()],
          fields: <TaxonomyLabelField>[TaxonomyLabelField.NAME],
        ),
      );
}
