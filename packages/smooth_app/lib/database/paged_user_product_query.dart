import 'dart:convert';

import 'package:http/http.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:openfoodfacts/utils/UriHelper.dart';
import 'package:smooth_app/database/paged_product_query.dart';
import 'package:smooth_app/database/product_query.dart';

/// Back-end paged queries around User.
abstract class PagedUserProductQuery extends PagedProductQuery {
  PagedUserProductQuery(this.userId);

  final String userId;

  @override
  Future<SearchResult> getSearchResult() async => _searchProducts(
        getPath(),
        ProductQuery.getUser(),
        pageSize,
        pageNumber,
        OpenFoodAPIConfiguration.globalQueryType,
      );

  String getPath();

  static Future<SearchResult> _searchProducts(
    // TODO(monsieurtanuki): move to off-dart, but probably not as is
    final String path,
    final User user,
    final int pageSize,
    final int pageNumber,
    final QueryType? queryType,
  ) async {
    final List<String> fields = convertFieldsToStrings(
      ProductQuery.fields,
      <OpenFoodFactsLanguage>[ProductQuery.getLanguage()!],
    );
    final Uri uri = UriHelper.getUri(
      path: path,
      queryType: queryType,
      queryParameters: <String, String>{
        'page_size': '$pageSize',
        'page': '$pageNumber',
        'fields': fields.join(','),
      },
    );
    final Response response = await HttpHelper().doGetRequest(
      uri,
      queryType: queryType,
      user: OpenFoodAPIConfiguration.globalUser,
    );
    final String jsonStr = response
        .body; // TODO(monsieurtanuki): what about _replaceQuotes(response.body);
    final SearchResult result = SearchResult.fromJson(
      json.decode(jsonStr) as Map<String, dynamic>,
    );

    // TODO(monsieurtanuki): what about _removeImages(result, configuration);

    return result;
  }
}
