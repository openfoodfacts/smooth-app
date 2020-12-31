import 'dart:async';

import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/full_products_database.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

class KeywordsProductQuery extends ProductQuery {
  KeywordsProductQuery(this.keywords) : super();

  final String keywords;

  @override
  Future<SearchResult> runInnerQuery() async =>
      await OpenFoodAPIClient.searchProducts(
        FullProductsDatabase.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: FullProductsDatabase.fields,
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
}
