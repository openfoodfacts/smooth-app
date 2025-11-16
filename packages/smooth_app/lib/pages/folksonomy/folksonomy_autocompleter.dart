import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

const int MIN_QUERY_LENGTH = 2;

class FolksonomyKeysAutocompleter implements Autocompleter {
  const FolksonomyKeysAutocompleter({this.limit = 10}) : assert(limit > 0);

  final int limit;

  @override
  Future<List<String>> getSuggestions(String input) async {
    if (input.trim().length < MIN_QUERY_LENGTH) {
      return <String>[];
    }

    final Map<String, KeyStats> keyStats = await FolksonomyAPIClient.getKeys(
      query: input,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );

    final List<String> keys = keyStats.keys.toList(growable: false)..sort();
    if (keys.length > limit) {
      return keys.take(limit).toList(growable: false);
    }
    return keys;
  }
}

class FolksonomyValuesAutocompleter implements Autocompleter {
  const FolksonomyValuesAutocompleter({
    required this.keyProvider,
    this.limit = 10,
  });
  final String Function() keyProvider;
  final int limit;

  @override
  Future<List<String>> getSuggestions(String input) async {
    input = input.trim();
    final String key = keyProvider().trim();
    if (input.length < MIN_QUERY_LENGTH || key.isEmpty) {
      return <String>[];
    }

    final Map<String, ValueCount> counts = await FolksonomyAPIClient.getValues(
      key: key,
      query: input,
      uriHelper: ProductQuery.uriFolksonomyHelper,
      limit: limit,
    );
    return counts.keys.toList();
  }
}
