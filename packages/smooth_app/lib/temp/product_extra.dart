// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';

class ProductExtra {
  // TODO(stephanegigandet): move to Product as non-static method getAttribute(final String attributeId)
  static Attribute getAttribute(
    final Product product,
    final String attributeId,
  ) {
    if (product == null) {
      return null;
    }
    if (attributeId == null) {
      return null;
    }
    if (product.attributeGroups == null) {
      return null;
    }
    for (final AttributeGroup attributeGroup in product.attributeGroups) {
      if (attributeGroup.attributes == null) {
        continue;
      }
      for (final Attribute attribute in attributeGroup.attributes) {
        if (attribute.id == attributeId) {
          return attribute;
        }
      }
    }
    return null;
  }
}
