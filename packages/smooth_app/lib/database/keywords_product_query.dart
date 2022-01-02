import 'dart:async';

import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

class KeywordsProductQuery implements ProductQuery {
  KeywordsProductQuery({
    required this.keywords,
    required this.size,
  });

  final String keywords;
  final int size;

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: size),
            SearchTerms(terms: <String>[keywords]),
          ],
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );

  @override
  ProductList getProductList() => ProductList.keywordSearch(keywords);

  @override
  String toString() => 'KeywordsProductQuery("$keywords", $size)';
}
