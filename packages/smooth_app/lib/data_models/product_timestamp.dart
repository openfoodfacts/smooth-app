import 'package:openfoodfacts/openfoodfacts.dart';

/// Abstract timestamp getter for [Product].
abstract class ProductTimestamp {
  /// Returns a timestamp as number of millis in UTC since Epoch
  Future<int?> getTimestamp(final Product product);
}
