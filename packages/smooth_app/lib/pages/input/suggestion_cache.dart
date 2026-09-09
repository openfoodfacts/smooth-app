import 'package:smooth_app/database/dao_autocomplete.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/input/server_suggestion.dart';

class SuggestionCache {
  SuggestionCache({
    required this.serverSuggestion,
    required this.localDatabase,
  });

  final ServerSuggestion serverSuggestion;
  final LocalDatabase localDatabase;

  static final Map<String, int> _namespaceIdCache = <String, int>{};
  static final Map<String, List<String>> _resultsCache =
      <String, List<String>>{};

  Future<int> _getNamespaceId(final String namespace) async {
    final int? cached = _namespaceIdCache[namespace];
    if (cached != null) {
      return cached;
    }
    final int id = await DaoNamespace(localDatabase).getOrCreateId(namespace);
    return _namespaceIdCache[namespace] = id;
  }

  Future<List<String>> getSuggestions(final String soFar) async {
    final String namespace = serverSuggestion.getNamespace();
    final int namespaceId = await _getNamespaceId(namespace);
    final String cacheKey = '$namespaceId|$soFar';

    // 1. Static
    final List<String>? static_ = _resultsCache[cacheKey];
    if (static_ != null) {
      return static_;
    }

    final DaoAutocompleteCache daoCache = DaoAutocompleteCache(localDatabase);

    // 2. DB
    final List<String>? db = await daoCache.get(namespaceId, soFar);
    if (db != null) {
      return _resultsCache[cacheKey] = db;
    }

    // 3. Server
    final List<String> results = await serverSuggestion
        .getSuggestionsFromServer(soFar);
    if (results.isNotEmpty) {
      await daoCache.put(namespaceId, soFar, results);
      _resultsCache[cacheKey] = results;
    }
    return results;
  }
}
