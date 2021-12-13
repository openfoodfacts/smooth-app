import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

/// [ProductListSupplier] with a server query flavor
class QueryProductListSupplier extends ProductListSupplier {
  QueryProductListSupplier(
    final ProductQuery productQuery,
    final LocalDatabase localDatabase,
  ) : super(productQuery, localDatabase);

  @override
  Future<String?> asyncLoad() async {
    try {
      final SearchResult searchResult = await productQuery.getSearchResult();
      productList = productQuery.getProductList();
      if (searchResult.products != null) {
        productList.setAll(searchResult.products!);
        await DaoProduct(localDatabase).putAll(searchResult.products!);
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
