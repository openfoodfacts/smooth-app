import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

class PreloadDataHelper {
  PreloadDataHelper(this.daoProduct);

  final DaoProduct daoProduct;

  /// We load the top 1000 products (without knowledge panels,
  /// so that we could keep a large volume of data in the localdb) from the openfoodfacts api
  /// then if any of those products are not in the local database, we add them to the local database.
  /// And if any of those products are in the local database, we check if they don't have knowledges we add them to the local database.
  /// If any of those products are in the local database and have knowledges,we don't add them to the local database.
  Future<int> downloadTopProducts() async {
    try {
      final List<ProductField> fields = ProductQuery.fields;
      fields.remove(ProductField.KNOWLEDGE_PANELS);
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
        return 0;
      } else {
        int totalProductsSaved = 0;
        for (final Product product in searchResult.products!) {
          if (await _isToBeUpdated(product)) {
            await daoProduct.put(product);
            totalProductsSaved++;
          }
        }
        return totalProductsSaved;
      }
    } on SocketException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> _isToBeUpdated(Product product) async {
    final Product? localProduct = await daoProduct.get(product.barcode!);
    if (localProduct == null) {
      return true;
    }
    return localProduct.knowledgePanels == null;
  }
}
