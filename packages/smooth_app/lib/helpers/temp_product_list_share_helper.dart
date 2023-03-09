import 'package:openfoodfacts/openfoodfacts.dart';

// TODO(m123): Move this to off-dart
Uri shareProductList(List<String> barcodes) {
  final StringBuffer buffer = StringBuffer();

  for (final String i in barcodes) {
    buffer.write('$i,');
  }

  return Uri(
    scheme: OpenFoodAPIConfiguration.uriScheme,
    host:
        '${OpenFoodAPIConfiguration.globalLanguages?.first.code ?? 'world'}.openfoodfacts.org',
    path: 'products/$buffer',
  );
}
