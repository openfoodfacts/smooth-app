import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

/// Import / Export of product lists via json.
class ProductListImportExport {
  static const String TMP_IMPORT = '{'
      '"list": ["3760020507350", "7300400481588", "3502110009449"],'
      '"data":{'
      '"12345": {"qty":5}'
      '}'
      '}';

  Future<void> import(
    final String jsonEncoded,
    final LocalDatabase localDatabase,
  ) async {
    final dynamic map = json.decode(jsonEncoded);
    if (map is! Map<String, dynamic>) {
      throw Exception('Expected Map<String, dynamic>');
    }
    final dynamic list = map['list'];
    if (list is! List<dynamic>) {
      throw Exception('Expected List<dynamic>');
    }
    final List<String> inputBarcodes = <String>[];
    for (final dynamic barcode in list) {
      inputBarcodes.add(barcode as String);
    }
    final SearchResult searchResult = await OpenFoodAPIClient.getProductList(
      ProductQuery.getUser(),
      ProductListQueryConfiguration(
        inputBarcodes,
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
      ),
    );
    if (searchResult.products == null) {
      return;
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final Map<String, Product> products = <String, Product>{};
    for (final Product product in searchResult.products!) {
      products[product.barcode!] = product;
      await daoProduct.put(product);
    }
    final List<String> barcodes = <String>[];
    for (final String barcode in inputBarcodes) {
      if (products.containsKey(barcode)) {
        barcodes.add(barcode);
      }
    }
    final ProductList productList = ProductList.history();
    productList.set(barcodes, products);
    await daoProductList.put(productList);
  }
}
