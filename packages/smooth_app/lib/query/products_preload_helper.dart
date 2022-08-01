import 'dart:io';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

class PreloadDataHelper {
  PreloadDataHelper(this.daoProduct);
  DaoProduct daoProduct;
  Future<String> getTopProducts() async {
    List<String> allProductCodes = await daoProduct.getAllKeys();
    final Map<String, Product> allProducts =
        await daoProduct.getAll(allProductCodes);
    allProducts.removeWhere(
        (String key, Product value) => value.knowledgePanels == null);
    allProductCodes = allProducts.keys.toList();
    final List<ProductField> fields = ProductQuery.fields;
    fields.remove(ProductField.KNOWLEDGE_PANELS);
    try {
      final ProductSearchQueryConfiguration queryConfig =
          ProductSearchQueryConfiguration(
        fields: fields,
        parametersList: <Parameter>[
          const PageSize(size: 1000),
          const PageNumber(page: 1),
          const SortBy(option: SortOption.POPULARITY),
        ],
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
      );
      final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        queryConfig,
      );
      if (searchResult.products!.isEmpty) {
        return 'No products found for your country and language';
      } else {
        searchResult.products!.removeWhere(
          (Product searchProduct) {
            return allProductCodes.contains(searchProduct.barcode);
          },
        );
        await daoProduct.putAll(searchResult.products!);
        return '${searchResult.products!.length} unique products added to the database for instant scan';
      }
    } on SocketException {
      return 'No internet connection';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
