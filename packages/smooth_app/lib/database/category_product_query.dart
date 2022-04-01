import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/paged_product_query.dart';

/// Back-end query about a category.
class CategoryProductQuery extends PagedProductQuery {
  CategoryProductQuery(this.categoryTag);

  // e.g. 'en:unsweetened-natural-soy-milks'
  final String categoryTag;

  @override
  Parameter getParameter() => TagFilter.fromType(
        tagFilterType: TagFilterType.CATEGORIES,
        contains: true,
        tagName: categoryTag,
      );

  @override
  ProductList getProductList() => ProductList.categorySearch(
        categoryTag,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

  @override
  String toString() =>
      'CategoryProductQuery("$categoryTag", $pageSize, $pageNumber)';
}
