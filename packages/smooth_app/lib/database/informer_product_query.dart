import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_user_product_query.dart';

/// User Product Search, in "informer" mode.
class InformerProductQuery extends PagedUserProductQuery {
  InformerProductQuery(final String userId) : super(userId);

  @override
  ProductList getProductList() => ProductList.informer(
        userId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String getPath() => 'informer/$userId.json';

  @override
  String toString() =>
      'InformerProductQuery("$userId", $pageSize, $pageNumber)';
}
