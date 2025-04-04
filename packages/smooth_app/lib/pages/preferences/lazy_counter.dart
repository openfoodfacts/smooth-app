import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/search_products_manager.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Lazy Counter, with a cached value stored locally, and a call to the server.
abstract class LazyCounter {
  const LazyCounter();

  /// Returns the value cached locally;
  int? getLocalCount(final UserPreferences userPreferences) =>
      userPreferences.getLazyCount(getSuffixTag());

  /// Sets the value cached locally;
  Future<void> setLocalCount(
    final int value,
    final UserPreferences userPreferences, {
    required final bool notify,
  }) =>
      userPreferences.setLazyCount(
        value,
        getSuffixTag(),
        notify: notify,
      );

  /// Returns the suffix tag used to cache the value locally;
  @protected
  String getSuffixTag();

  /// Gets the latest value from the server.
  Future<int?> getServerCount();
}

/// Lazy Counter dedicated to Prices counts.
class LazyCounterPrices extends LazyCounter {
  const LazyCounterPrices(this.owner);

  final String? owner;

  @override
  String getSuffixTag() => 'P_$owner';

  @override
  Future<int?> getServerCount() async {
    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()
        ..owner = owner
        ..pageSize = 1,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (result.isError) {
      return null;
    }
    return result.value.total;
  }
}

/// Lazy Counter dedicated to OFF User Search counts.
class LazyCounterUserSearch extends LazyCounter {
  const LazyCounterUserSearch(this.type);

  final UserSearchType type;

  @override
  String getSuffixTag() => 'US_$type';

  @override
  Future<int?> getServerCount() async {
    final User user = ProductQuery.getWriteUser();
    final ProductSearchQueryConfiguration configuration = type.getConfiguration(
      user.userId,
      1,
      1,
      ProductQuery.getLanguage(),
      // one field is enough as we want only the count
      // and we need at least one field (no field meaning all fields)
      <ProductField>[ProductField.BARCODE],
    );

    try {
      final SearchResult result = await SearchProductsManager.searchProducts(
        user,
        configuration,
        uriHelper: ProductQuery.getUriProductHelper(
          productType: ProductType.food,
        ),
        type: SearchProductsType.count,
      );
      return result.count;
    } catch (e) {
      Logs.e(
        'Could not count the number of products for $type, ${user.userId}',
        ex: e,
      );
      return null;
    }
  }
}
