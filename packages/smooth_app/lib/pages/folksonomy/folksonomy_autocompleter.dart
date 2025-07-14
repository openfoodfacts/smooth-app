import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

class FolksonomyKeysAutocompleter implements Autocompleter {
  const FolksonomyKeysAutocompleter({this.limit = 15});

  final int limit;

  @override
  Future<List<String>> getSuggestions(String input) async {
    if (input.trim().length < 2) {
      return <String>[];
    }

    final Map<String, KeyStats> keyStats = await FolksonomyAPIClient.getKeys(
      query: input,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );

    final List<String> keys = keyStats.keys.toList()..sort();
    if (keys.length > limit) {
      return keys.sublist(0, limit);
    }
    return keys;
  }
}

class FolksonomyValuesAutocompleter implements Autocompleter {
  const FolksonomyValuesAutocompleter({
    required this.keyProvider,
    this.limit = 15,
  });
  final String Function() keyProvider;
  final int limit;

  @override
  Future<List<String>> getSuggestions(String input) async {
    final String q = input.trim();
    final String key = keyProvider().trim();
    if (q.length < 2 || key.isEmpty) {
      return <String>[];
    }

    final Map<String, ValueCount> counts = await FolksonomyAPIClient.getValues(
      key: key,
      query: q,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );

    final List<String> values = counts.keys.toList()..sort();
    return values.take(limit).toList();
  }
}
