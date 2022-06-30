import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/UserProductSearchQueryConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_product_query.dart';
import 'package:smooth_app/database/product_query.dart';

/// Back-end paged queries around User.
class PagedUserProductQuery extends PagedProductQuery {
  PagedUserProductQuery({
    required this.userId,
    required this.type,
  });

  final String userId;
  final UserProductSearchType type;

  @override
  Future<SearchResult> getSearchResult() async => OpenFoodAPIClient.getProducts(
        ProductQuery.getUser(),
        UserProductSearchQueryConfiguration(
          type: type,
          userId: userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: ProductQuery.getLanguage(),
          fields: ProductQuery.fields,
        ),
        queryType: OpenFoodAPIConfiguration.globalQueryType,
      );

  @override
  ProductList getProductList() {
    switch (type) {
      case UserProductSearchType.CONTRIBUTOR:
        return ProductList.contributor(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      case UserProductSearchType.INFORMER:
        return ProductList.informer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      case UserProductSearchType.PHOTOGRAPHER:
        return ProductList.photographer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
      case UserProductSearchType.TO_BE_COMPLETED:
        return ProductList.toBeCompleted(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
        );
    }
  }

  @override
  String toString() =>
      'PagedUserProductQuery($type, "$userId", $pageSize, $pageNumber)';
}
