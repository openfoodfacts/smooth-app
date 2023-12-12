import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(List<String> barcodes) {
  final String barcodesString = barcodes.join(',');

  return UriHelper.replaceSubdomain(
    ProductQuery.uriProductHelper.getUri(
      path: 'products/$barcodesString',
      addUserAgentParameters: false,
    ),
    language: OpenFoodAPIConfiguration.globalLanguages?.first,
  );
}
