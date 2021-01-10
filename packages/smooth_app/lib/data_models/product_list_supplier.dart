import 'package:smooth_app/data_models/product_list.dart';

abstract class ProductListSupplier {
  /// returns null if OK, or the message error
  Future<String> asyncLoad();

  ProductList getProductList();

  bool needsToBeSavedIntoDb();
}
