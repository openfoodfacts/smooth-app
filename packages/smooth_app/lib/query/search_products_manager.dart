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
    return OpenFoodAPIClient.searchProducts(
      user,
      configuration,
      uriHelper: uriHelper,
    );
  }
}
