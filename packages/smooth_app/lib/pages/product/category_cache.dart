import 'package:openfoodfacts/openfoodfacts.dart';

/// Cache where we download and store category data.
class CategoryCache {
  CategoryCache(this.language);

  /// Current app language.
  final OpenFoodFactsLanguage language;

  /// Languages for category translations.
  List<OpenFoodFactsLanguage> get _languages => <OpenFoodFactsLanguage>[
        language,
        _alternateLanguage,
      ];

  /// Where we keep everything we've already downloaded.
  final Map<String, TaxonomyCategory> _cache = <String, TaxonomyCategory>{};

  /// Where we keep the tags we've tried to download but found nothing.
  ///
  /// e.g. 'ru:хлеб-украинский-новый', child of 'en:breads'
  final Set<String> _unknown = <String>{};

  /// Alternate language, where it's relatively safe to find translations.
  static const OpenFoodFactsLanguage _alternateLanguage =
      OpenFoodFactsLanguage.ENGLISH;

  /// Fields we retrieve.
  static const List<TaxonomyCategoryField> _fields = <TaxonomyCategoryField>[
    TaxonomyCategoryField.NAME,
    TaxonomyCategoryField.CHILDREN,
    TaxonomyCategoryField.PARENTS,
  ];

  /// Returns the siblings AND the father (for tree climbing reasons).
  Future<Map<String, TaxonomyCategory>?> getCategorySiblingsAndFather({
    required final String fatherTag,
  }) async {
    final Map<String, TaxonomyCategory> fatherData =
        await _getCategories(<String>[fatherTag]);
    if (fatherData.isEmpty) {
      return null;
    }
    final List<String>? siblingTags = fatherData[fatherTag]?.children;
    if (siblingTags == null || siblingTags.isEmpty) {
      return fatherData;
    }
    final Map<String, TaxonomyCategory> result =
        await _getCategories(siblingTags);
    if (result.isNotEmpty) {
      result[fatherTag] = fatherData[fatherTag]!;
    }
    return result;
  }

  /// Returns the best translation of the category name.
  String? getBestCategoryName(final TaxonomyCategory category) {
    String? result;
    if (category.name != null) {
      result ??= category.name![language];
      result ??= category.name![_alternateLanguage];
    }
    return result;
  }

  /// Returns categories, locally cached is possible, or from BE.
  Future<Map<String, TaxonomyCategory>> _getCategories(
    final List<String> tags,
  ) async {
    final List<String> alreadyTags = <String>[];
    final List<String> neededTags = <String>[];
    for (final String tag in tags) {
      if (_unknown.contains(tag)) {
        continue;
      }
      if (_cache.containsKey(tag)) {
        alreadyTags.add(tag);
      } else {
        neededTags.add(tag);
      }
    }
    final Map<String, TaxonomyCategory>? partialResult;
    if (neededTags.isEmpty) {
      partialResult = null;
    } else {
      partialResult = await _downloadCategories(neededTags);
    }
    final Map<String, TaxonomyCategory> result = <String, TaxonomyCategory>{};
    if (partialResult != null) {
      _cache.addAll(partialResult);
      result.addAll(partialResult);
      for (final String tag in neededTags) {
        if (!partialResult.containsKey(tag)) {
          _unknown.add(tag);
        }
      }
    }
    for (final String tag in alreadyTags) {
      result[tag] = _cache[tag]!;
    }
    return result;
  }

  // TODO(monsieurtanuki): add loading dialog

  /// Downloads categories from the BE.
  Future<Map<String, TaxonomyCategory>?> _downloadCategories(
    final List<String> tags,
  ) async =>
      OpenFoodAPIClient.getTaxonomyCategories(
        TaxonomyCategoryQueryConfiguration(
          tags: tags,
          fields: _fields,
          languages: _languages,
        ),
      );
}
