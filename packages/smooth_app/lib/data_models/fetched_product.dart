import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Status of a "fetch [Product]" operation
enum FetchedProductStatus {
  // found locally or from internet
  ok,
  internetNotFound,
  internetError,
  userCancelled,
  // TODO(monsieurtanuki): time-out
}

/// A [Product] that we tried to fetch, but was it successful?..
class FetchedProduct {
  const FetchedProduct._({
    required this.status,
    this.product,
    this.isConnected,
    this.exceptionString,
    this.failedPingedHost,
  });

  // The reason behind the "ignore": I want to force "product" to be not null
  const FetchedProduct.found(final Product product)
    // ignore: prefer_initializing_formals
    : this._(status: FetchedProductStatus.ok, product: product);

  /// The internet Product search said it couldn't find the product.
  const FetchedProduct.internetNotFound()
    : this._(status: FetchedProductStatus.internetNotFound);

  /// The user cancelled the operation.
  const FetchedProduct.userCancelled()
    : this._(status: FetchedProductStatus.userCancelled);

  /// When the "fetch product" operation had an internet error.
  const FetchedProduct.error({
    required final String exceptionString,
    required final bool isConnected,
    final String? failedPingedHost,
  }) : this._(
         status: FetchedProductStatus.internetError,
         isConnected: isConnected,
         exceptionString: exceptionString,
         failedPingedHost: failedPingedHost,
       );

  final Product? product;
  final FetchedProductStatus status;

  /// When relevant, returns true if connected.
  final bool? isConnected;

  /// When relevant, string of the exception.
  final String? exceptionString;

  /// When relevant, host of the query that we couldn't even ping.
  final String? failedPingedHost;

  String getErrorTitle(final AppLocalizations appLocalizations) {
    switch (status) {
      case FetchedProductStatus.ok:
        return 'Not supposed to happen...';
      case FetchedProductStatus.userCancelled:
        return 'Not supposed to happen either...';
      case FetchedProductStatus.internetNotFound:
        return appLocalizations.product_refresher_internet_not_found;
      case FetchedProductStatus.internetError:
        if (isConnected == false) {
          return appLocalizations.product_refresher_internet_not_connected;
        }
        if (failedPingedHost != null) {
          return appLocalizations.product_refresher_internet_no_ping(
            failedPingedHost,
          );
        }
        return appLocalizations.product_refresher_internet_no_ping(
          exceptionString,
        );
    }
  }

  /// A valid product needs to have photos (otherwise, we consider it as new)
  bool get isValid =>
      product?.statesTags != null &&
      !product!.statesTags!.contains('en:photos-to-be-uploaded');
}
