import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'product_timestamp.dart';

/// Product timestamp taken from the local database upsert timestamp.
class ProductDatabaseTimestamp implements ProductTimestamp {
  ProductDatabaseTimestamp(final LocalDatabase localDatabase)
      : _daoProduct = DaoProduct(localDatabase);

  final DaoProduct _daoProduct;

  @override
  Future<int?> getTimestamp(final Product product) async {
    if (product.barcode == null) {
      return null;
    }
    return _daoProduct.getLastUpdate(product.barcode!);
  }
}
