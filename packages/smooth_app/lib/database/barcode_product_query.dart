// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:openfoodfacts/openfoodfacts.dart';

// Project imports:
import 'package:smooth_app/database/product_query.dart';

class BarcodeProductQuery {
  BarcodeProductQuery({
    @required this.barcode,
    @required this.languageCode,
    @required this.countryCode,
  });

  final String barcode;
  final String languageCode;
  final String countryCode;

  Future<Product> getProduct() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      lc: languageCode,
      cc: countryCode,
    );

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      return result.product;
    }
    return null;
  }
}
