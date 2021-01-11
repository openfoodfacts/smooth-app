import 'dart:async';

import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/data_models/product_list.dart';

class KeywordsProductQuery implements ProductQuery {
  KeywordsProductQuery(this.keywords);

  final String keywords;

  @override
  Future<SearchResult> getSearchResult() async =>
      await OpenFoodAPIClient.searchProducts(
        ProductQuery.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            const PageSize(size: 500),
            TagFilter(
              tagType: 'categories',
              contains: true,
              tagName: keywords,
            )
          ],
          language: OpenFoodFactsLanguage.ENGLISH,
        ),
      );

  @override
  ProductList getProductList() => ProductList(
        listType: ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS,
        parameters: keywords,
      );
}
