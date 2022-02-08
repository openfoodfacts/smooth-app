import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

class DatabaseProductListSupplier extends ProductListSupplier {
  DatabaseProductListSupplier(
    final ProductQuery productQuery,
    final LocalDatabase localDatabase,
    final int timestamp,
  ) : super(productQuery, localDatabase, timestamp: timestamp);

  @override
  Future<String?> asyncLoad() async {
    try {
      final ProductList loadedProductList = productQuery.getProductList();
      await DaoProductList(localDatabase).get(loadedProductList);
      productList = loadedProductList;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  ProductListSupplier getRefreshSupplier() =>
      QueryProductListSupplier(productQuery, localDatabase);
}
