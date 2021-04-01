// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';

class ProductExtra {
  // TODO(stephanegigandet): move to Product as non-static method getAttributes(final List<String> attributeIds)
  /// Returns all existing product attributes matching a list of attribute ids
  static Map<String, Attribute> getAttributes(
    final Product product,
    final List<String> attributeIds,
  ) {
    final Map<String, Attribute> result = <String, Attribute>{};
    if (product.attributeGroups == null) {
      return result;
    }
    for (final AttributeGroup attributeGroup in product.attributeGroups) {
      if (attributeGroup.attributes == null) {
        continue;
      }
      for (final Attribute attribute in attributeGroup.attributes) {
        final String attributeId = attribute.id;
        if (attributeIds.contains(attributeId)) {
          result[attributeId] = attribute;
        }
      }
    }
    return result;
  }
}
