import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(
  final List<String> barcodes,
  final ProductType productType,
) {
  final String barcodesString = barcodes.join(',');

  return UriHelper.replaceSubdomain(
    ProductQuery.getUriProductHelper(productType: productType).getUri(
      path: 'products/$barcodesString',
      addUserAgentParameters: false,
    ),
    language: OpenFoodAPIConfiguration.globalLanguages?.first,
  );
}
