import 'package:openfoodfacts/utils/AbstractQueryConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/preferences/tmp_to_be_completed_query_configuration.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged query for all "to-be-completed" products.
class PagedToBeCompletedProductQuery extends PagedProductQuery {
  @override
  AbstractQueryConfiguration getQueryConfiguration() =>
      ToBeCompletedQueryConfiguration(
        pageSize: pageSize,
        pageNumber: pageNumber,
        language: language,
        country: country,
        fields: ProductQuery.fields,
      );

  @override
  ProductList getProductList() => ProductList.allToBeCompleted(
        pageSize: pageSize,
        pageNumber: pageNumber,
        language: language,
        country: country,
      );

  @override
  String toString() => 'PagedToBeCompletedProductQuery('
      '$pageSize'
      ', $pageNumber'
      ', $language'
      ', $country'
      ')';
}
