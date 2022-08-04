import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_search_product_query.dart';

/// Back-end query about a category.
class CategoryProductQuery extends PagedSearchProductQuery {
  CategoryProductQuery(this.categoryTag, {super.world});

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
        language: language,
        country: country,
      );

  @override
  String toString() => 'CategoryProductQuery('
      '"$categoryTag"'
      ', $pageSize'
      ', $pageNumber'
      ', $language'
      ', $country'
      ')';

  @override
  PagedProductQuery? getWorldQuery() =>
      world ? null : CategoryProductQuery(categoryTag, world: true);

  @override
  bool hasDifferentCountryWorldData() => true;
}
