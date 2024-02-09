import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

/// Manager that returns the elastic suggestions for the latest brand input.
///
/// See also: [SuggestionManager].
class BrandSuggestionManager {
  BrandSuggestionManager({
    this.limit = 25,
    this.user,
  });

  final int limit;
  final User? user;

  final List<String> _inputs = <String>[];
  final Map<String, List<String>> _cache = <String, List<String>>{};

  /// Returns suggestions about the latest input.
  Future<List<String>> getSuggestions(
    final String input,
  ) async {
    _inputs.add(input);
    final List<String>? cached = _cache[input];
    if (cached != null) {
      return cached;
    }
    final AutocompleteSearchResult result =
        await OpenFoodSearchAPIClient.autocomplete(
      query: input,
      taxonomyNames: <TaxonomyName>[TaxonomyName.brand],
      // for brands, language must be English
      language: OpenFoodFactsLanguage.ENGLISH,
      user: ProductQuery.getReadUser(),
      size: limit,
      fuzziness: Fuzziness.none,
    );
    final List<String> tmp = <String>[];
    if (result.options != null) {
      for (final AutocompleteSingleResult option in result.options!) {
        final String text = option.text;
        if (!tmp.contains(text)) {
          tmp.add(text);
        }
      }
    }
    _cache[input] = tmp;
    // meanwhile there might have been some calls to this method, adding inputs.
    for (final String latestInput in _inputs.reversed) {
      final List<String>? cached = _cache[latestInput];
      if (cached != null) {
        return cached;
      }
    }
    // not supposed to happen, as we should have downloaded for "input".
    return <String>[];
  }
}
