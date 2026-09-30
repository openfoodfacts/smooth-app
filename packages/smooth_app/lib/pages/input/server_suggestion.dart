import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_autocompleter.dart';
import 'package:smooth_app/query/product_query.dart';

/// Abstract interface for server-backed autocomplete with cache namespace support.
abstract class ServerSuggestion {
  String getNamespace();
  Future<List<String>> getSuggestionsFromServer(String soFar);
}

/// Implementation for TagType autocompleters (categories, labels, origins, etc.)
class TagTypeServerSuggestion implements ServerSuggestion {
  TagTypeServerSuggestion({required this.tagType, required this.productType});

  final TagType tagType;
  final ProductType productType;

  OpenFoodFactsLanguage get _language => ProductQuery.getLanguage();
  OpenFoodFactsCountry? get _country => ProductQuery.getCountry();
  UriProductHelper get _uriHelper =>
      ProductQuery.getUriProductHelper(productType: productType);

  @override
  String getNamespace() {
    return '${_uriHelper.domain}|tagtype|${tagType.offTag}|${_language.offTag}|${_country?.offTag ?? ''}';
  }

  @override
  Future<List<String>> getSuggestionsFromServer(String soFar) async {
    final TagTypeAutocompleter autocompleter = TagTypeAutocompleter(
      tagType: tagType,
      language: _language,
      country: _country,
      uriHelper: _uriHelper,
      limit: 15,
    );
    return autocompleter.getSuggestions(soFar);
  }
}

/// Implementation for TaxonomyName autocompleters (brands)
class TaxonomyServerSuggestion implements ServerSuggestion {
  TaxonomyServerSuggestion({
    required this.taxonomyNames,
    required this.productType,
  });

  final List<TaxonomyName> taxonomyNames;
  final ProductType productType;

  OpenFoodFactsLanguage get _language => OpenFoodFactsLanguage.ENGLISH;
  UriProductHelper get _uriHelper =>
      ProductQuery.getUriProductHelper(productType: productType);

  @override
  String getNamespace() {
    return '${_uriHelper.domain}|taxonomy|${taxonomyNames.map((final TaxonomyName t) => t.offTag).join(',')}|${_language.offTag}';
  }

  @override
  Future<List<String>> getSuggestionsFromServer(String soFar) async {
    final TaxonomyNameAutocompleter autocompleter = TaxonomyNameAutocompleter(
      taxonomyNames: taxonomyNames,
      language: _language,
      uriHelper: _uriHelper,
      limit: 25,
      fuzziness: Fuzziness.none,
      user: ProductQuery.getReadUser(),
    );
    return autocompleter.getSuggestions(soFar);
  }
}

/// Implementation for folksonomy keys autocompleter
class FolksonomyKeysServerSuggestion implements ServerSuggestion {
  const FolksonomyKeysServerSuggestion();

  UriHelper get _uriHelper => ProductQuery.uriFolksonomyHelper;

  @override
  String getNamespace() {
    return '${_uriHelper.host}|folksonomy|keys';
  }

  @override
  Future<List<String>> getSuggestionsFromServer(String soFar) async {
    const FolksonomyKeysAutocompleter autocompleter =
        FolksonomyKeysAutocompleter(limit: 10);
    return autocompleter.getSuggestions(soFar);
  }
}

/// Implementation for folksonomy values autocompleter
class FolksonomyValuesServerSuggestion implements ServerSuggestion {
  FolksonomyValuesServerSuggestion({required String Function() keyProvider})
    : _keyProvider = keyProvider;

  final String Function() _keyProvider;

  UriHelper get _uriHelper => ProductQuery.uriFolksonomyHelper;

  @override
  String getNamespace() {
    final String key = _keyProvider().trim();
    return '${_uriHelper.host}|folksonomy|values|$key';
  }

  @override
  Future<List<String>> getSuggestionsFromServer(String soFar) async {
    final FolksonomyValuesAutocompleter autocompleter =
        FolksonomyValuesAutocompleter(keyProvider: _keyProvider, limit: 10);
    return autocompleter.getSuggestions(soFar);
  }
}
