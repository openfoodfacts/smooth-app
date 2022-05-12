import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';

/// Paged product query (with [pageSize] and [pageNumber]).
abstract class PagedProductQuery implements ProductQuery {
  final int pageSize = _typicalPageSize;

  /// Likely to change: to next page, and back to top.
  int _pageNumber = _startPageNumber;

  int get pageNumber => _pageNumber;

  static const int _typicalPageSize = 25;
  static const int _startPageNumber = 1;

  void toNextPage() => _pageNumber++;

  void toTopPage() => _pageNumber = _startPageNumber;

  Parameter getParameter();

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: pageSize),
            PageNumber(page: _pageNumber),
            getParameter(),
          ],
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );
}
