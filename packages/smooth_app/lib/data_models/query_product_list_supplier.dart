import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/model/SearchResult.dart';

class QueryProductListSupplier implements ProductListSupplier {
  QueryProductListSupplier(this.productQuery);

  final ProductQuery productQuery;
  ProductList _productList;

  @override
  ProductList getProductList() => _productList;

  @override
  Future<String> asyncLoad() async {
    try {
      final SearchResult searchResult = await productQuery.getSearchResult();
      _productList = productQuery.getProductList();
      _productList.addAll(searchResult.products);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  bool needsToBeSavedIntoDb() => true;

  @override
  ProductListSupplier getRefreshSupplier() => null;
}
