import 'package:openfoodfacts/model/Product.dart';

/// Status of a "fetch [Product]" operation
enum FetchedProductStatus {
  ok,
  internetNotFound,
  internetError,
  userCancelled,
  // TODO(monsieurtanuki): time-out
}

/// A [Product] that we tried to fetch, but was it successful?..
class FetchedProduct {
  // The reason behind the "ignore": I want to force "product" to be not null
  FetchedProduct(final Product product)
      // ignore: prefer_initializing_formals
      : product = product,
        status = FetchedProductStatus.ok;

  /// When the "fetch product" operation didn't go well (no status "ok" here)
  FetchedProduct.error(this.status)
      : product = null,
        assert(status != FetchedProductStatus.ok);

  final Product? product;
  final FetchedProductStatus status;
}
