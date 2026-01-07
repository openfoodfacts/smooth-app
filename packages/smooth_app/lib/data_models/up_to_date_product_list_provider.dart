import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_interest.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects the latest barcode lists on [ProductList]s.
class UpToDateProductListProvider {
  UpToDateProductListProvider(this.localDatabase);

  final LocalDatabase localDatabase;

  /// Product lists currently displayed in the app.
  ///
  /// We need to know which product lists are "interesting" because we need to
  /// cache barcode lists in memory for instant access. And we should cache only
  /// them, because we cannot cache all product lists in memory.
  final UpToDateInterest _interest = UpToDateInterest();

  final Map<String, List<String>> _barcodes = <String, List<String>>{};

  /// Shows an interest for a product list.
  ///
  /// Typically, to be used by a widget in `initState`.
  void showInterest(final ProductList productList) =>
      _interest.add(_getKey(productList));

  /// Loses interest for a product list.
  ///
  /// Typically, to be used by a widget in `dispose`.
  void loseInterest(final ProductList productList) {
    final String key = _getKey(productList);
    if (!_interest.remove(key)) {
      return;
    }
    _barcodes.remove(key);
  }

  String _getKey(final ProductList productList) =>
      DaoProductList.getKey(productList);

  void setLocalUpToDate(final String key, final List<String> barcodes) {
    if (!_interest.containsKey(key)) {
      return;
    }
    _barcodes[key] = List<String>.from(barcodes); // need to copy
  }

  /// Returns the latest barcodes.
  List<String> getLocalUpToDate(final ProductList productList) =>
      _barcodes[_getKey(productList)] ?? <String>[];
}
