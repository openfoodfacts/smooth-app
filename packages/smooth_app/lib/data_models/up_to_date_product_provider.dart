import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider {
  UpToDateProductProvider(this.localDatabase);

  final LocalDatabase localDatabase;

  final Map<String, Product> _map = <String, Product>{};
  final Map<String, int> _timestamps = <String, int>{};

  /// Latest downloaded product for a barcode.
  final Map<String, Product> _latestDownloadedProducts = <String, Product>{};

  /// Barcodes currently displayed in the app.
  ///
  /// We need to know which barcodes are "interesting" because we need to cache
  /// products in memory for instant access. And we should cache only them,
  /// because we cannot cache all products in memory.
  final Map<String, int> _interestingBarcodes = <String, int>{};

  Product? get(final Product product) => _map[product.barcode!];

  Product? getFromBarcode(final String barcode) => _map[barcode];

  void set(final Product product) {
    _map[product.barcode!] = product;
    _timestamps[product.barcode!] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Returns true if at least one barcode was refreshed after the [timestamp].
  bool needsRefresh(final int? latestTimestamp, final List<String> barcodes) {
    if (latestTimestamp == null) {
      // no need to "refresh", need to start instead!
      return false;
    }
    for (final String barcode in barcodes) {
      final int? timestamp = _timestamps[barcode];
      if (timestamp != null && timestamp > latestTimestamp) {
        return true;
      }
    }
    return false;
  }

  /// Shows an interest for a barcode.
  ///
  /// Typically, to be used by a widget in `initState`.
  void showInterest(final String barcode) {
    final int result = (_interestingBarcodes[barcode] ?? 0) + 1;
    _interestingBarcodes[barcode] = result;
  }

  /// Loses interest for a barcode.
  ///
  /// Typically, to be used by a widget in `dispose`.
  void loseInterest(final String barcode) {
    final int result = (_interestingBarcodes[barcode] ?? 0) - 1;
    if (result <= 0) {
      _interestingBarcodes.remove(barcode);
      _latestDownloadedProducts.remove(barcode);
      _timestamps.remove(barcode);
    } else {
      _interestingBarcodes[barcode] = result;
    }
  }

  /// Typical use-case: a product page is refreshed through a pull-gesture.
  void setLatestDownloadedProduct(
    final Product product, {
    final bool notify = true,
  }) {
    _latestDownloadedProducts[product.barcode!] = product;
    _timestamps[product.barcode!] = LocalDatabase.nowInMillis();
    if (notify) {
      localDatabase.notifyListeners();
    }
  }

  /// Typical use-case: a product list page is refreshed through a pull-gesture.
  void setLatestDownloadedProducts(
    final Iterable<Product> products, {
    final bool notify = true,
  }) {
    if (_interestingBarcodes.isEmpty) {
      return;
    }
    bool atLeastOne = false;
    for (final Product product in products) {
      if (_interestingBarcodes.containsKey(product.barcode)) {
        atLeastOne = true;
        setLatestDownloadedProduct(product, notify: false);
      }
    }
    if (notify && atLeastOne) {
      localDatabase.notifyListeners();
    }
  }
}
