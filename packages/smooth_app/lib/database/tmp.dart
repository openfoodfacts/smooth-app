import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:openfoodfacts/utils/UriHelper.dart';

/// Fixes to off-dart.
// TODO(monsieurtanuki): to be moved to off-dart
class OpenFoodAPIClientTmp {
  OpenFoodAPIClientTmp._();

  /// Returns the product for the given barcode.
  /// The ProductResult does not contain a product, if the product is not available.
  /// ingredients, images and product name will be prepared for the given language.
  ///
  /// Please read the language mechanics explanation if you intend to show
  /// or update data in specific language: https://github.com/openfoodfacts/openfoodfacts-dart/blob/master/DOCUMENTATION.md#about-languages-mechanics
  static Future<ProductResult> getProduct(
    ProductQueryConfiguration configuration, {
    User? user,
    QueryType? queryType,
  }) async {
    final String jsonStr = await getProductString(
      configuration,
      user: user,
      queryType: queryType,
    );
    final ProductResult result =
        ProductResult.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

    if (result.product != null) {
      ProductHelper.removeImages(result.product!, configuration.language);
      ProductHelper.createImageUrls(result.product!, queryType: queryType);
    }

    return result;
  }

  static Future<String> getProductString(
    final ProductQueryConfiguration configuration, {
    final User? user,
    final QueryType? queryType,
  }) async {
    final Uri uri = UriHelper.getUri(
      path: 'api/v0/product/${configuration.barcode}.json',
      queryParameters: configuration.getParametersMap(),
      queryType: queryType,
    );

    final Response response = await HttpHelper().doGetRequest(
      uri,
      user: user,
      queryType: queryType,
    );
    return _replaceQuotes(response.body);
  }

  static String _replaceQuotes(String str) {
    return str.replaceAll('&quot;', r'\"');
  }

  /// Returns all KnowledgePanels for a product.
  static Future<KnowledgePanels> getKnowledgePanels(
    final ProductQueryConfiguration configuration, {
    final QueryType? queryType,
  }) async {
    final String jsonString =
        await getKnowledgePanelsString(configuration, queryType: queryType);
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<String, dynamic> product =
        json['product'] as Map<String, dynamic>;
    final Map<String, dynamic> knowledgePanelsJson =
        product[OpenFoodAPIClientTmp.KNOWLEDGE_PANELS_FIELD]
            as Map<String, dynamic>;
    return KnowledgePanels.fromJson(knowledgePanelsJson);
  }

  static const String KNOWLEDGE_PANELS_FIELD = 'knowledge_panels';

  /// Returns all KnowledgePanels for a product.
  static Future<String> getKnowledgePanelsString(
    final ProductQueryConfiguration configuration, {
    final QueryType? queryType,
  }) async {
    final Map<String, String> queryParameters = <String, String>{
      'fields': KNOWLEDGE_PANELS_FIELD,
      'lc': configuration.language!.code,
    };
    final String? cc = configuration.computeCountryCode();
    if (cc != null) {
      queryParameters['cc'] = cc;
    }
    final Uri uri = UriHelper.getUri(
      path: 'api/v2/product/${configuration.barcode}/',
      queryType: queryType,
      queryParameters: queryParameters,
    );

    final Response response = await HttpHelper().doGetRequest(
      uri,
      queryType: queryType,
    );
    if (response.statusCode != 200) {
      throw Exception('no knowledge panel found');
    }
    return response.body;
  }
}
