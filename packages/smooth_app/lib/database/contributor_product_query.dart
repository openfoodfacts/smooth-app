import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_user_product_query.dart';

/// User Product Search, in "contributor" mode.
class ContributorProductQuery extends PagedUserProductQuery {
  ContributorProductQuery(final String userId) : super(userId);

  @override
  ProductList getProductList() => ProductList.contributor(
        userId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String getPath() => 'contributor/$userId.json';

  @override
  String toString() =>
      'ContributorProductQuery("$userId", $pageSize, $pageNumber)';
}
