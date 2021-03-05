// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

class DatabaseProductListSupplier implements ProductListSupplier {
  DatabaseProductListSupplier(this.productQuery, this.localDatabase);

  final ProductQuery productQuery;
  final LocalDatabase localDatabase;
  ProductList _productList;

  @override
  ProductList getProductList() => _productList;

  @override
  Future<String> asyncLoad() async {
    try {
      final ProductList productList = productQuery.getProductList();
      final bool result = await DaoProductList(localDatabase).get(productList);
      if (!result) {
        return 'unexpected empty record';
      }
      _productList = productList;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  bool needsToBeSavedIntoDb() => false;

  @override
  ProductListSupplier getRefreshSupplier() =>
      QueryProductListSupplier(productQuery);
}
