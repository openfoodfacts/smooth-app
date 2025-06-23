import 'package:openfoodfacts/openfoodfacts.dart';

/// Type of long download work for some background tasks.
enum WorkType {
  /// Top products.
  offline(tag: 'O', englishLabel: 'Top products'),

  /// Fresh products with Knowledge Panels.
  freshKP(tag: 'K', englishLabel: 'Refresh products with KP'),

  /// Fresh products without Knowledge Panels.
  freshNoKP(tag: 'w', englishLabel: 'Refresh products without KP');

  const WorkType({required this.tag, required this.englishLabel});

  final String tag;
  final String englishLabel;

  String getWorkTag(final ProductType productType) =>
      '$tag:${productType.offTag}';

  static (WorkType, ProductType)? extract(final String string) {
    if (string.isEmpty) {
      return null;
    }
    final List<String> strings = string.split(':');
    if (strings.length > 2) {
      return null;
    }
    final ProductType productType;
    if (strings.length == 1) {
      productType = ProductType.food;
    } else {
      productType = ProductType.fromOffTag(strings[1])!;
    }
    final WorkType workType = fromTag(strings[0])!;
    return (workType, productType);
  }

  static WorkType? fromTag(final String tag) {
    for (final WorkType workType in values) {
      if (workType.tag == tag) {
        return workType;
      }
    }
    return null;
  }
}
