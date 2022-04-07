import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/data_models/partial_product_list.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/paged_product_query.dart';

/// Asynchronously loads a [ProductList] with products
abstract class ProductListSupplier {
  ProductListSupplier(
    this.productQuery,
    this.localDatabase, {
    this.timestamp,
  });

  final PagedProductQuery productQuery;
  final LocalDatabase localDatabase;
  final int? timestamp;
  final PartialProductList partialProductList = PartialProductList();

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad();

  /// Returns a helper supplier in order to refresh the data
  ProductListSupplier? getRefreshSupplier();

  /// Clears the database and restarts from top page.
  Future<void> clear() async {
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    productQuery.toTopPage();
    while (await daoProductList.delete(productQuery.getProductList())) {
      productQuery.toNextPage();
    }

    productQuery.toTopPage();

    partialProductList.clear();
  }

  /// Returns the fastest data supplier: database if possible, or server query
  static Future<ProductListSupplier> getBestSupplier(
    final PagedProductQuery productQuery,
    final LocalDatabase localDatabase,
  ) async {
    final int? timestamp = await DaoProductList(localDatabase).getTimestamp(
      productQuery.getProductList(),
    );
    return timestamp == null
        ? QueryProductListSupplier(productQuery, localDatabase)
        : DatabaseProductListSupplier(productQuery, localDatabase, timestamp);
  }
}
