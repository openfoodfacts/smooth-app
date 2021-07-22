import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/dao_product.dart';

class BarcodeProductQuery {
  BarcodeProductQuery({
    required this.barcode,
    required this.languageCode,
    required this.countryCode,
    required this.daoProduct,
  });

  final String barcode;
  final String languageCode;
  final String countryCode;
  final DaoProduct daoProduct;

  Future<Product?> getProduct() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: LanguageHelper.fromJson(languageCode),
      cc: countryCode,
    );

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      final Product? product = result.product;
      if (product != null) {
        await daoProduct.put(<Product>[product]);
      }
      return product;
    }
    return null;
  }
}
