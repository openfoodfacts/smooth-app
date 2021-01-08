import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

class BarcodeProductQuery {
  BarcodeProductQuery(this.barcode);

  final String barcode;

  Future<Product> getProduct() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: OpenFoodFactsLanguage.ENGLISH,
    );

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      return result.product;
    }
    return null;
  }
}
