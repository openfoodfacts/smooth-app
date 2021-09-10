import 'package:openfoodfacts/openfoodfacts.dart';
import 'product_timestamp.dart';

/// Product timestamp taken from the "last modified" OFF field.
class ProductOffTimestamp implements ProductTimestamp {
  @override
  Future<int?> getTimestamp(final Product product) async {
    if (product.lastModified == null) {
      return null;
    }
    return product.lastModified!.millisecondsSinceEpoch;
  }
}
