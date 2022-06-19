import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_user_product_query.dart';

/// User Product Search, in "to be completed" mode.
class ToBeCompletedProductQuery extends PagedUserProductQuery {
  ToBeCompletedProductQuery(final String userId) : super(userId);

  @override
  ProductList getProductList() => ProductList.toBeCompleted(
        userId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String getPath() => 'informer/$userId/state/to-be-completed.json';

  @override
  String toString() =>
      'ToBeCompletedProductQuery("$userId", $pageSize, $pageNumber)';
}
