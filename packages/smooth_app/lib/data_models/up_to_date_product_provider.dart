import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider with ChangeNotifier {
  final Map<String, Product> _map = <String, Product>{};

  Product? get(final Product product) => _map[product.barcode!];

  void set(
    final Product product, {
    final bool notify = true,
  }) {
    _map[product.barcode!] = product;
    if (notify) {
      notifyListeners();
    }
  }
}
