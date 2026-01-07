import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(
  final List<String> barcodes,
  final ProductType productType,
) {
  final StringBuffer barcodesString = StringBuffer();
  for (final String barcode in barcodes) {
    if (barcodesString.isNotEmpty) {
      barcodesString.write('+');
    }

    barcodesString.write(Uri.encodeComponent(barcode));
  }

  return UriHelper.replaceSubdomain(
    ProductQuery.getUriProductHelper(
      productType: productType,
    ).getUri(path: 'products/$barcodesString', addUserAgentParameters: false),
    language: OpenFoodAPIConfiguration.globalLanguages?.first,
  );
}
