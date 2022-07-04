import 'package:openfoodfacts/utils/AbstractQueryConfiguration.dart';
import 'package:openfoodfacts/utils/UserProductSearchQueryConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged queries around User.
class PagedUserProductQuery extends PagedProductQuery {
  PagedUserProductQuery({
    required this.userId,
    required this.type,
  });

  final String userId;
  final UserProductSearchType type;

  @override
  AbstractQueryConfiguration getQueryConfiguration() =>
      UserProductSearchQueryConfiguration(
        type: type,
        userId: userId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        language: language,
        fields: ProductQuery.fields,
      );

  @override
  ProductList getProductList() {
    switch (type) {
      case UserProductSearchType.CONTRIBUTOR:
        return ProductList.contributor(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
        );
      case UserProductSearchType.INFORMER:
        return ProductList.informer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
        );
      case UserProductSearchType.PHOTOGRAPHER:
        return ProductList.photographer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
        );
      case UserProductSearchType.TO_BE_COMPLETED:
        return ProductList.toBeCompleted(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
        );
    }
  }

  @override
  String toString() => 'PagedUserProductQuery('
      '$type'
      ', "$userId"'
      ', $pageSize'
      ', $pageNumber'
      ', $language'
      ')';
}
