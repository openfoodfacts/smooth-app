import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/paged_search_product_query.dart';

/// Back-end query around user-entered keywords.
class KeywordsProductQuery extends PagedSearchProductQuery {
  KeywordsProductQuery(this.keywords);

  final String keywords;

  @override
  Parameter getParameter() => SearchTerms(terms: <String>[keywords]);

  @override
  ProductList getProductList() => ProductList.keywordSearch(
        keywords,
        pageSize: pageSize,
        pageNumber: pageNumber,
        language: language,
        country: country,
      );

  @override
  String toString() => 'KeywordsProductQuery('
      '"$keywords"'
      ', $pageSize'
      ', $pageNumber'
      ', $language'
      ', $country'
      ')';
}
