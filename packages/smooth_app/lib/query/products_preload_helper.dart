import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

class PreloadDataHelper {
  PreloadDataHelper(this.daoProduct);
  DaoProduct daoProduct;

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
      if (searchResult.products!.isEmpty) {
        return 'No products found';
      } else {
        await daoProduct.putAll(searchResult.products!);
        return '${searchResult.products!.length} products added to the database for instant scan';
      }
    } on SocketException {
      return 'No internet connection';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> updateKnowledgePanels() async {
    final List<String> allBarcodes = await daoProduct.getAllKeys();
    final List<String> toUpdateFully = <String>[];
    final Map<String, Product> productsWithKnowledgePanels =
        await daoProduct.getAll(allBarcodes);
    productsWithKnowledgePanels.forEach((String barcode, Product product) {
      if (product.knowledgePanels != null) {
        toUpdateFully.add(barcode);
      }
    });
    if (toUpdateFully.isEmpty) {
      return 'Products already up to date';
    }
    List<String> chunks = <String>[];
    int totalUpdatedYet = 0;
    for (int i = 0; i < toUpdateFully.length; i += 500) {
      if (i + 500 < toUpdateFully.length) {
        chunks = toUpdateFully.sublist(i, i + 500);
      } else {
        chunks = toUpdateFully.sublist(i, toUpdateFully.length);
      }
      final ProductListQueryConfiguration configuration =
          ProductListQueryConfiguration(
        chunks,
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        pageSize: 500,
      );
      try {
        final SearchResult searchResult =
            await OpenFoodAPIClient.getProductList(
                ProductQuery.getUser(), configuration);
        if (searchResult.products!.isEmpty) {
          return 'No products found';
        } else {
          totalUpdatedYet += searchResult.products!.length;
          await daoProduct.putAll(searchResult.products!);
        }
      } on SocketException {
        return 'No internet connection';
      } catch (e) {
        return 'Error: $e';
      }
    }
    return '$totalUpdatedYet products fully Loaded';
  }
}
