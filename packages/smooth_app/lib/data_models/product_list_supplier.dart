import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/data_models/partial_product_list.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/paged_product_query.dart';

/// Asynchronously loads a [ProductList] with products
abstract class ProductListSupplier {
  ProductListSupplier(this.productQuery, this.localDatabase, {this.timestamp});

  final PagedProductQuery productQuery;
  final LocalDatabase localDatabase;
  final int? timestamp;
  final PartialProductList partialProductList = PartialProductList();

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad();

  /// Returns a helper supplier in order to refresh the data
  ProductListSupplier? getRefreshSupplier();

  /// Clears the database from page 2.
  ///
  /// Use-case: we have data on several pages, and the user wants to launch
  /// the search again. That means
  /// * all cached results are deprecated
  /// * we start again a search from top page
  /// * we should clear ALL pages
  /// * but we clear only from page 2 and if the search didn't crash (server ko)
  /// * in order to play it safe - when it crashes we still have data
  Future<void> clearBeyondTopPage() async {
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    productQuery.toTopPage();
    do {
      productQuery.toNextPage();
    } while (await daoProductList.delete(productQuery.getProductList()));
    productQuery.toTopPage();
  }

  /// Returns the fastest data supplier: database if possible, or server query
  static Future<ProductListSupplier> getBestSupplier(
    final PagedProductQuery productQuery,
    final LocalDatabase localDatabase,
  ) async {
    final int? timestamp = await DaoProductList(
      localDatabase,
    ).getTimestamp(productQuery.getProductList());
    return timestamp == null
        ? QueryProductListSupplier(productQuery, localDatabase)
        : DatabaseProductListSupplier(productQuery, localDatabase, timestamp);
  }
}
