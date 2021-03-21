// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';

/// cf. https://github.com/openfoodfacts/smooth-app/issues/39
class Match {
  Match(
    final Product product,
    final ProductPreferences productPreferences,
  ) {
    final List<AttributeGroup> attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      _status = null;
      return;
    }
    for (final AttributeGroup group in attributeGroups) {
      for (final Attribute attribute in group.attributes) {
        final PreferenceImportance preferenceImportance =
            productPreferences.getPreferenceImportanceFromImportanceId(
          productPreferences.getImportanceIdForAttributeId(
            attribute.id,
          ),
        );
        final String value = preferenceImportance.id;
        final int factor = preferenceImportance.factor ?? 0;
        final int minimalMatch = preferenceImportance.minimalMatch;
        if (value == null || factor == 0) {
          _debug += '${attribute.id} $value\n';
        } else {
          if (attribute.status == _UNKNOWN_STATUS) {
            if (_status ?? false) {
              _status = null;
            }
          } else {
            _debug += '${attribute.id} $value - match: ${attribute.match}\n';
            _score += attribute.match * factor;
            if (minimalMatch != null && attribute.match <= minimalMatch) {
              _status = false;
            }
          }
        }
      }
    }
  }

  static const String _UNKNOWN_STATUS = 'unknown';
  static const String KNOWN_STATUS = 'known';

  double _score = 0;
  bool _status = true;
  String _debug = '';

  double get score => _score;
  bool get status => _status;
  String get debug => _debug;

  static List<RankedProduct> sort(
    final List<Product> products,
    final ProductPreferences productPreferences,
  ) {
    final List<RankedProduct> result = <RankedProduct>[];
    for (final Product product in products) {
      final Match match = Match(product, productPreferences);
      result.add(RankedProduct(product: product, match: match));
    }
    result.sort((RankedProduct a, RankedProduct b) =>
        b.match.score.compareTo(a.match.score));
    return result;
  }

  // return a map of all existing product attributes matching a list of attribute ids
  static Map<String, Attribute> getMatchingAttributes(
    final Product product,
    final List<String> attributeIds,
  ) {
    final Map<String, Attribute> result = <String, Attribute>{};
    final List<AttributeGroup> attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      return result;
    }
    for (final AttributeGroup group in attributeGroups) {
      for (final Attribute attribute in group.attributes) {
        final String attributeId = attribute.id;
        if (attributeIds.contains(attributeId)) {
          result[attributeId] = attribute;
        }
      }
    }
    return result;
  }
}
