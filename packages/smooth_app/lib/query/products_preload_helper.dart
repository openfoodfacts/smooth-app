import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

class PreloadDataHelper {
  PreloadDataHelper(this.daoProduct);

  final DaoProduct daoProduct;

  Future<String> getTopProducts() async {
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
      if (searchResult.products?.isEmpty ?? true) {
        return 'No products found for your country and language';
      } else {
        final List<Product> productsToBePushed = <Product>[];
        for (int i = 0; i < searchResult.products!.length; i++) {
          if (await _isToBeUpdated(searchResult.products![i])) {
            productsToBePushed.add(searchResult.products![i]);
          }
        }
        await daoProduct.putAll(productsToBePushed);
        return '${productsToBePushed.length} unique products added to the database for instant scan';
      }
    } on SocketException {
      return 'No internet connection';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<bool> _isToBeUpdated(Product product) async {
    if (await daoProduct.get(product.barcode!) == null) {
      return true;
    } else {
      final Product? localProduct = await daoProduct.get(product.barcode!);
      if (localProduct!.knowledgePanels == null) {
        return true;
      } else {
        return false;
      }
    }
  }
}
