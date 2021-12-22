import 'dart:async';
import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

class KeywordsProductQuery implements ProductQuery {
  KeywordsProductQuery({
    required this.keywords,
    required this.language,
    required this.country,
    required this.size,
  });

  final String keywords;
  final OpenFoodFactsLanguage? language;
  final OpenFoodFactsCountry? country;
  final int size;

  @override
  Future<SearchResult> getSearchResult() async =>
      OpenFoodAPIClient.searchProducts(
        ProductQuery.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          parametersList: <Parameter>[
            PageSize(size: size),
            SearchTerms(terms: <String>[keywords]),
          ],
          language: language,
          country: country,
        ),
      );

  @override
  ProductList getProductList() => ProductList.keywordSearch(keywords);

  @override
  String toString() => 'KeywordsProductQuery('
      '"$keywords"'
      ', $language'
      ', $country'
      ', $size'
      ')';
}
