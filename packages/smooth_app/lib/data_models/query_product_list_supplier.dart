import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';

/// [ProductListSupplier] with a server query flavor
class QueryProductListSupplier extends ProductListSupplier {
  QueryProductListSupplier(super.productQuery, super.localDatabase);

  @override
  Future<String?> asyncLoad() async {
    try {
      final SearchResult searchResult = await productQuery.getSearchResult();
      final ProductList productList = productQuery.getProductList();
      partialProductList.clear();
      if (searchResult.products != null) {
        productList.setAll(searchResult.products!);
        productList.totalSize = searchResult.count ?? 0;
        partialProductList.add(productList);
        final DaoProduct daoProduct = DaoProduct(localDatabase);
        final Map<String, Product> localProducts = await daoProduct.getAll(
          searchResult.products!.map(
            (final Product product) => product.barcode!,
          ),
        );
        // Search results come without knowledge panels: we don't overwrite
        // local products that have some.
        await daoProduct.putAll(
          searchResult.products!.where(
            (final Product product) =>
                product.knowledgePanels != null ||
                localProducts[product.barcode]?.knowledgePanels == null,
          ),
          productQuery.language,
          productType: productQuery.productType,
        );
      }
      await DaoProductList(localDatabase).put(productList);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  ProductListSupplier? getRefreshSupplier() => null;
}
