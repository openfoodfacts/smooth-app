import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper around the language priority.
///
/// cf. https://github.com/openfoodfacts/smooth-app/issues/4996
class LanguagePriority {
  LanguagePriority({
    required final Product? product,
    required final Iterable<OpenFoodFactsLanguage>? selectedLanguages,
    required final DaoStringList daoStringList,
  }) {
    _addAll(selectedLanguages);
    _addStringList(daoStringList.getAll(DaoStringList.keyLanguages));
    _add(ProductQuery.getLanguage());
    if (product == null) {
      return;
    }
    _add(product.lang);
    _addMap(product.productNameInLanguages);
    _addImages(product.images);
    _addMap(product.packagingTextInLanguages);
    _addMap(product.ingredientsTextInLanguages);
    _addMap(product.labelsTagsInLanguages);
    _addMap(product.categoriesTagsInLanguages);
    _addMap(product.countriesTagsInLanguages);
  }

  final List<OpenFoodFactsLanguage> _languages = <OpenFoodFactsLanguage>[];

  void _addMap(final Map<OpenFoodFactsLanguage, dynamic>? map) {
    if (map == null) {
      return;
    }
    _addAll(map.keys);
  }

  void _addImages(final Iterable<ProductImage>? productImages) {
    if (productImages == null) {
      return;
    }
    for (final ProductImage productImage in productImages) {
      _add(productImage.language);
    }
  }

  void _add(final OpenFoodFactsLanguage? language) {
    if (language == null) {
      return;
    }
    if (_languages.contains(language)) {
      return;
    }
    _languages.add(language);
  }

  void _addString(final String languageCode) {
    try {
      final OpenFoodFactsLanguage? language =
          OpenFoodFactsLanguage.fromOffTag(languageCode);
      _add(language);
    } catch (e) {
      // just ignore
    }
  }

  void _addStringList(final List<String> languageCodes) =>
      languageCodes.forEach(_addString);

  void _addAll(final Iterable<OpenFoodFactsLanguage>? languages) {
    if (languages == null) {
      return;
    }
    languages.forEach(_add);
  }

  int? compare(final OpenFoodFactsLanguage a, final OpenFoodFactsLanguage b) {
    final bool selectedA = _languages.contains(a);
    final bool selectedB = _languages.contains(b);
    if (selectedA) {
      if (!selectedB) {
        return -1;
      }
    } else {
      if (selectedB) {
        return 1;
      }
    }
    return null;
  }
}
