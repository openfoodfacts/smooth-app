import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/paged_product_query.dart';
import 'package:smooth_app/database/product_query.dart';

/// Back-end paged queries around search.
abstract class PagedSearchProductQuery extends PagedProductQuery {
  Parameter getParameter();

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: pageSize),
            PageNumber(page: pageNumber),
            getParameter(),
          ],
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );
}
