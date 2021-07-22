import 'dart:async';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

/// Product query dedicated to category (e.g. 'en:mueslis-with-fruits')
class CategoryProductQuery implements ProductQuery {
  CategoryProductQuery({
    required this.category,
    required this.languageCode,
    required this.countryCode,
    required this.size,
  });

  final String category;
  final String languageCode;
  final String countryCode;
  final int size;

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: size),
            TagFilter(
              tagType: 'categories',
              contains: true,
              tagName: category,
            ),
          ],
          language: LanguageHelper.fromJson(languageCode),
          cc: countryCode,
        ),
      );

  @override
  ProductList getProductList() => ProductList(
        listType: ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY,
        parameters: category,
      );

  @override
  String toString() => 'CategoryProductQuery('
      '$category'
      ', $languageCode'
      ', $countryCode'
      ', $size'
      ')';
}
