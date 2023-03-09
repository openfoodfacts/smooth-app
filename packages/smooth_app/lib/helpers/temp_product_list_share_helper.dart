import 'package:openfoodfacts/openfoodfacts.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(List<String> barcodes) {
  final StringBuffer buffer = StringBuffer();

  for (final String i in barcodes) {
    buffer.write('$i,');
  }

  return UriHelper.replaceSubdomain(
    UriHelper.getUri(
      path: 'products/$buffer',
      addUserAgentParameters: false,
    ),
    language: OpenFoodAPIConfiguration.globalLanguages?.first,
  );
}
