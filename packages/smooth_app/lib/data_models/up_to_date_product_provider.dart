import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider with ChangeNotifier {
  final Map<String, Product> _map = <String, Product>{};
  final Map<String, int> _timestamps = <String, int>{};

  Product? get(final Product product) => _map[product.barcode!];

  Product? getFromBarcode(final String barcode) => _map[barcode];

  void set(
    final Product product, {
    final bool notify = true,
  }) {
    _map[product.barcode!] = product;
    _timestamps[product.barcode!] = LocalDatabase.nowInMillis();
    if (notify) {
      notifyListeners();
    }
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
}
