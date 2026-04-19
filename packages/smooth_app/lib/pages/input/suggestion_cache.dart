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

  // namespace string → namespace DB id (avoids repeated DB lookup per session)
  final Map<String, int> _namespaceIdCache = <String, int>{};

  Future<int> _getNamespaceId(final String namespace) async {
    final int? cached = _namespaceIdCache[namespace];
    if (cached != null) {
      return cached;
    }
    final int id = await DaoNamespace(localDatabase).getOrCreateId(namespace);
    _namespaceIdCache[namespace] = id;
    return id;
  }

  Future<List<String>> getSuggestions(final String soFar) async {
    final String namespace = serverSuggestion.getNamespace(soFar);
    final int namespaceId = await _getNamespaceId(namespace);

    final DaoAutocompleteCache daoCache = DaoAutocompleteCache(localDatabase);

    // 1. DB
    final List<String>? db = await daoCache.get(namespaceId, soFar);
    if (db != null) {
      return db;
    }

    // 2. Server
    final List<String> results = await serverSuggestion
        .getSuggestionsFromServer(soFar);
    if (results.isNotEmpty) {
      await daoCache.put(namespaceId, soFar, results);
    }
    return results;
  }
}
