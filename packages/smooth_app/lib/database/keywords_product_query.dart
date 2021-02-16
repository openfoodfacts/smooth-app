import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:smooth_app/data_models/product_list.dart';

class KeywordsProductQuery implements ProductQuery {
  KeywordsProductQuery({
    @required this.keywords,
    @required this.languageCode,
    @required this.countryCode,
    @required this.size,
  });

  final String keywords;
  final String languageCode;
  final String countryCode;
  final int size;

  @override
  Future<SearchResult> getSearchResult() async =>
      await OpenFoodAPIClient.searchProducts(
        ProductQuery.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: size),
            TagFilter(
              tagType: 'categories',
              contains: true,
              tagName: keywords,
            ),
          ],
          lc: languageCode,
          cc: countryCode,
        ),
      );

  @override
  ProductList getProductList() => ProductList(
        listType: ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS,
        // TODO(monsieurtanuki): parameters should include languageCode, countryCode and pageSize
        parameters: keywords,
      );

  @override
  String toString() => 'KeywordsProductQuery('
      '"$keywords"'
      ', $languageCode'
      ', $countryCode'
      ', $size'
      ')';
}
