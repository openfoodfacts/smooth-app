import 'package:openfoodfacts/openfoodfacts.dart';

/// Interface for background tasks that change a product.
abstract class BackgroundTaskProductChange {
  /// Product change, as a minimal Product.
  Product getProductChange();
}
