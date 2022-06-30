import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_product_query.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/preferences/tmp_to_be_completed_query_configuration.dart';

/// Back-end paged query for all "to-be-completed" products.
class PagedToBeCompletedProductQuery extends PagedProductQuery {
  PagedToBeCompletedProductQuery();

  @override
  Future<SearchResult> getSearchResult() async => OpenFoodAPIClient.getProducts(
        ProductQuery.getUser(),
        ToBeCompletedQueryConfiguration(
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
          fields: ProductQuery.fields,
        ),
        queryType: OpenFoodAPIConfiguration.globalQueryType,
      );

  @override
  ProductList getProductList() => ProductList.allToBeCompleted(
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String toString() => 'ToBeCompletedPagedProductQuery($pageSize, $pageNumber)';
}
