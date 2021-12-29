import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/product_query.dart';

class BarcodeProductQuery {
  BarcodeProductQuery({
    required this.barcode,
    required this.daoProduct,
  });

  final String barcode;
  final DaoProduct daoProduct;

  Future<FetchedProduct> getFetchedProduct() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: ProductQuery.getLanguage(),
      country: ProductQuery.getCountry(),
    );

    final ProductResult result;
    try {
      result = await OpenFoodAPIClient.getProduct(configuration);
    } catch (e) {
      return FetchedProduct.error(FetchedProductStatus.internetError);
    }

    if (result.status == 1) {
      final Product? product = result.product;
      if (product != null) {
        await daoProduct.put(product);
        return FetchedProduct(product);
      }
    }
    return FetchedProduct.error(FetchedProductStatus.internetNotFound);
  }
}
