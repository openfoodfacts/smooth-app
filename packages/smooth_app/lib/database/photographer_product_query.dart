import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_user_product_query.dart';

/// User Product Search, in "photographer" mode.
class PhotographerProductQuery extends PagedUserProductQuery {
  PhotographerProductQuery(final String userId) : super(userId);

  @override
  ProductList getProductList() => ProductList.photographer(
        userId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String getPath() => 'photographer/$userId.json';

  @override
  String toString() =>
      'PhotographerProductQuery("$userId", $pageSize, $pageNumber)';
}
