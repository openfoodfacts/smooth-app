import 'package:openfoodfacts/openfoodfacts.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(List<String> barcodes) {
  final StringBuffer buffer = StringBuffer();

  for (String i in barcodes) {
    buffer.write('$i,');
  }

  return UriHelper.getUri(
    path: 'products/$buffer',
    addUserAgentParameters: false,
  );
}
