import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Type of "search products" action.
enum SearchProductsType {
  /// For heavy background tasks like offline downloads.
  background,

  /// For live user interactions in the app.
  live,

  /// For counts like "number of products I edited".
  count;

  /// General threshold: 10 requests per minute.
  static final TooManyRequestsManager _generalRequestManager =
      TooManyRequestsManager(
        maxCount: 10,
        duration: const Duration(minutes: 1),
      );

  /// Specific threshold for background tasks.
  static final TooManyRequestsManager _backgroundRequestManager =
      TooManyRequestsManager(maxCount: 3, duration: const Duration(minutes: 1));

  /// Specific threshold for count tasks.
  ///
  /// For the record there are currently 4 counts displayed.
  static final TooManyRequestsManager _countRequestManager =
      TooManyRequestsManager(maxCount: 4, duration: const Duration(minutes: 1));

  Future<void> _specificWaitIfNeeded() async => switch (this) {
    SearchProductsType.background => _backgroundRequestManager.waitIfNeeded(),
    SearchProductsType.count => _countRequestManager.waitIfNeeded(),
    SearchProductsType.live => null,
  };

  Future<void> waitIfNeeded() async {
    await _specificWaitIfNeeded();
    await _generalRequestManager.waitIfNeeded();
  }
}

/// Management of "search products" access limitations.
class SearchProductsManager {
  SearchProductsManager._();

  static Future<SearchResult> searchProducts(
    final User? user,
    final AbstractQueryConfiguration configuration, {
    required final UriProductHelper uriHelper,
    required final SearchProductsType type,
  }) async {
    await type.waitIfNeeded();

    // It's better to do the HTTP actions outside of "compute", because
    // there are init phases for HTTP (like user agent and SSL certificates)
    // that would need to be somehow replicated for a new "compute thread".
    // Besides, putting HTTP in "compute" wouldn't improve the performances.
    final Response response = await configuration.getResponse(user, uriHelper);
    TooManyRequestsException.check(response);

    final SearchResult result = await compute(_decodeProducts, response.body);
    _removeImages(result, configuration);
    return result;
  }

  static Future<SearchResult> _decodeProducts(
    final String responseBody,
  ) async => SearchResult.fromJson(
    HttpHelper().jsonDecode(_replaceQuotes(responseBody)),
  );

  // TODO(monsieurtanuki): somehow move to/make public in off-dart
  static String _replaceQuotes(String str) {
    const String needle = '&quot;';
    if (!str.contains(needle)) {
      return str;
    }
    return str.replaceAll(needle, r'\"');
  }

  // TODO(monsieurtanuki): somehow move to/make public in off-dart
  static void _removeImages(
    final SearchResult searchResult,
    final AbstractQueryConfiguration configuration,
  ) {
    if (searchResult.products != null) {
      searchResult.products!.asMap().forEach((int index, Product product) {
        ProductHelper.removeImages(product, configuration.language);
      });
    }
  }
}
