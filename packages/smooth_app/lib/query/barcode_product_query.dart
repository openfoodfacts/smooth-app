import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

class BarcodeProductQuery {
  BarcodeProductQuery({
    required this.barcode,
    required this.daoProduct,
    required this.isScanned,
  });

  final String barcode;
  final DaoProduct daoProduct;
  final bool isScanned;

  Future<FetchedProduct> getFetchedProduct() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: ProductQuery.getLanguage(),
      country: ProductQuery.getCountry(),
    );

    final ProductResult result;
    try {
      ProductQuery.setUserAgentComment(isScanned ? 'scan' : 'search');
      result = await OpenFoodAPIClient.getProduct(configuration);
    } catch (e) {
      ProductQuery.setUserAgentComment('');
      return FetchedProduct.error(FetchedProductStatus.internetError);
    }
    ProductQuery.setUserAgentComment('');

    if (result.status == 1) {
      final Product? product = result.product;
      if (product != null) {
        await daoProduct.put(product);
        return FetchedProduct(product);
      }
    }
    if (barcode.trim().isNotEmpty &&
        (result.barcode == null || result.barcode!.isEmpty)) {
      return FetchedProduct.error(FetchedProductStatus.codeInvalid);
    }
    return FetchedProduct.error(FetchedProductStatus.internetNotFound);
  }
}
