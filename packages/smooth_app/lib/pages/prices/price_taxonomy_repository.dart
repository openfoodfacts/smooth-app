import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper for tag localization using taxonomy.
abstract class PriceTaxonomyRepository<T> {
  /// Downloads the taxonomy for the given [tags].
  @protected
  Future<Map<String, T>?> download(List<String> tags);

  @protected
  Map<OpenFoodFactsLanguage, String>? getTaxonomyNames(T item);

  @protected
  Map<String, String> getCachedMap();

  Future<String?> getDownloadedName(String tag) async {
    final List<String>? result = await getDownloadedNames(<String>[tag]);
    if (result == null) {
      return null;
    }
    return result.firstOrNull;
  }

  Future<List<String>?> getDownloadedNames(List<String> tags) async {
    if (tags.isEmpty) {
      return null;
    }
    final OpenFoodFactsLanguage language = getLanguage();
    final Map<String, T>? map = await download(tags);
    if (map == null) {
      return null;
    }
    final List<String> result = <String>[];
    for (final String tag in tags) {
      String? toBeAdded;
      final T? item = map[tag];
      if (item != null) {
        final Map<OpenFoodFactsLanguage, String>? names = getTaxonomyNames(
          item,
        );
        if (names != null && names.isNotEmpty) {
          final String? label = names[language];
          if (label != null) {
            _setCachedName(tag, label);
            toBeAdded = label;
          }
        }
      }
      toBeAdded ??= tag;
      result.add(toBeAdded);
    }
    return result;
  }

  void _setCachedName(String tag, String label) =>
      getCachedMap()[_getKey(getLanguage(), getCountry(), tag)] = label;

  String? getCachedName(String tag) {
    final List<String>? result = getCachedNames(<String>[tag]);
    if (result == null) {
      return null;
    }
    return result.firstOrNull;
  }

  /// Returns the cached names if all are present, or null.
  List<String>? getCachedNames(List<String> tags) {
    final Map<String, String> map = getCachedMap();
    final OpenFoodFactsLanguage language = getLanguage();
    final OpenFoodFactsCountry country = getCountry();
    final List<String> result = <String>[];
    for (final String tag in tags) {
      final String key = _getKey(language, country, tag);
      final String? cached = map[key];
      if (cached == null) {
        return null;
      }
      result.add(cached);
    }
    return result;
  }

  @protected
  OpenFoodFactsLanguage getLanguage() => ProductQuery.getLanguage();

  @protected
  OpenFoodFactsCountry getCountry() => ProductQuery.getCountry();

  String _getKey(
    OpenFoodFactsLanguage language,
    OpenFoodFactsCountry country,
    String tag,
  ) => '${language.offTag}_${country.offTag}:$tag';
}
