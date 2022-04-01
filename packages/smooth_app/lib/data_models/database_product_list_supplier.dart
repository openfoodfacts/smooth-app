import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/paged_product_query.dart';

/// Supplier of previous back-end results now stored in the local database.
class DatabaseProductListSupplier extends ProductListSupplier {
  DatabaseProductListSupplier(
    final PagedProductQuery pagedProductQuery,
    final LocalDatabase localDatabase,
    final int timestamp,
  ) : super(pagedProductQuery, localDatabase, timestamp: timestamp);

  /// Loads all results page after page.
  @override
  Future<String?> asyncLoad() async {
    try {
      ProductList productList = productQuery.getProductList();
      bool first = true;
      do {
        await DaoProductList(localDatabase).get(productList);
        if (productList.barcodes.isEmpty) {
          if (first) {
            partialProductList.add(productList);
          }
          break;
        }
        partialProductList.add(productList);
        productQuery.toNextPage();
        productList = productQuery.getProductList();
        first = false;
      } while (true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  ProductListSupplier getRefreshSupplier() =>
      QueryProductListSupplier(productQuery, localDatabase);
}
