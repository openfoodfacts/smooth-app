import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/full_products_database.dart';

abstract class ProductQuery {
  ProductQuery();

  final FullProductsDatabase database = FullProductsDatabase();

  static const User SMOOTH_USER = FullProductsDatabase.SMOOTH_USER;
  static const List<ProductField> fields = FullProductsDatabase.fields;

  Future<SearchResult> runInnerQuery();

  Future<List<Product>> queryProducts() async {
    final SearchResult result = await runInnerQuery();
    database.saveProducts(result.products);
    return result.products;
  }
}
