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
      // we start from page 1
      ProductList productList = productQuery.getProductList();
      bool first = true;
      do {
        // we try to get the locally saved data for the current page
        await DaoProductList(localDatabase).get(productList);
        if (productList.barcodes.isEmpty) {
          // we found nothing
          if (first) {
            // we save an empty list
            partialProductList.add(productList);
          }
          // that's it, we've just loaded all the non-empty pages we could
          return null;
        }
        // we found something: let's add it to the partial product list
        partialProductList.add(productList);
        // and try again with the next page
        productQuery.toNextPage();
        productList = productQuery.getProductList();
        first = false;
      } while (true);
    } catch (e) {
      return e.toString();
    }
  }

  @override
  ProductListSupplier getRefreshSupplier() =>
      QueryProductListSupplier(productQuery, localDatabase);
}
