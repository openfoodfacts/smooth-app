import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/search_products_manager.dart';

/// Paged product query (with [pageSize] and [pageNumber]).
abstract class PagedProductQuery {
  PagedProductQuery({
    required this.productType,
    this.world = false,
  });

  final ProductType productType;
  final int pageSize = _typicalPageSize;

  /// Likely to change: to next page, and back to top.
  int _pageNumber = _startPageNumber;

  int get pageNumber => _pageNumber;

  final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
  OpenFoodFactsCountry? get country => world ? null : ProductQuery.getCountry();

  /// Is that the world mode (true), or the standard country mode (false).
  final bool world;

  /// Returns the same query but without country: "for the whole world".
  ///
  /// Null if not relevant (already in the "world" version, or no country).
  PagedProductQuery? getWorldQuery() => null;

  /// Is that a query that has potentially different data for country and world?
  bool hasDifferentCountryWorldData() => false;

  static const int _typicalPageSize = 25;
  static const int _startPageNumber = 1;

  void toNextPage() => _pageNumber++;

  void toTopPage() => _pageNumber = _startPageNumber;

  Future<SearchResult> getSearchResult() async =>
      SearchProductsManager.searchProducts(
        ProductQuery.getReadUser(),
        getQueryConfiguration(),
        uriHelper: ProductQuery.getUriProductHelper(productType: productType),
        type: SearchProductsType.live,
      );

  AbstractQueryConfiguration getQueryConfiguration();

  ProductList getProductList();
}
