import 'dart:async';

import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

/// Back-end query about a category.
class CategoryProductQuery implements ProductQuery {
  CategoryProductQuery({
    required this.categoryTag,
    required this.size,
  });

  // e.g. 'en:unsweetened-natural-soy-milks'
  final String categoryTag;
  final int size;

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: size),
            TagFilter.fromType(
              tagFilterType: TagFilterType.CATEGORIES,
              contains: true,
              tagName: categoryTag,
            ),
          ],
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );

  @override
  ProductList getProductList() => ProductList.categorySearch(categoryTag);

  @override
  String toString() => 'CategoryProductQuery("$categoryTag", $size)';
}
