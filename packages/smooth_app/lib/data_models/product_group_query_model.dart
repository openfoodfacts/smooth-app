
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/database/full_products_database.dart';

class ProductGroupQueryModel extends ChangeNotifier {

  ProductGroupQueryModel(this.group) {
    _loadData();
  }

  final PnnsGroup2 group;

  List<Product> products;
  FullProductsDatabase productsDatabase;

  Future<bool> _loadData() async {
    productsDatabase = FullProductsDatabase();

    products = await productsDatabase.queryPnnsGroup(group);

    notifyListeners();
    return true;
  }
}