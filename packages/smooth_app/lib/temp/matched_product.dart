// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/temp/attribute_extra.dart';

// Project imports:
import 'package:smooth_app/temp/preference_importance.dart';
import 'package:smooth_app/temp/product_preferences_manager.dart';

/// Match and score of a [Product] vs. Preferences
///
/// cf. https://github.com/openfoodfacts/smooth-app/issues/39
class MatchedProduct {
  MatchedProduct(
    this.product,
    final ProductPreferencesManager productPreferencesManager,
  ) {
    final List<AttributeGroup> attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      _status = null;
      return;
    }
    for (final AttributeGroup group in attributeGroups) {
      for (final Attribute attribute in group.attributes) {
        final PreferenceImportance preferenceImportance =
            productPreferencesManager.getPreferenceImportanceFromImportanceId(
          productPreferencesManager.getImportanceIdForAttributeId(
            attribute.id,
          ),
        );
        final String importanceId = preferenceImportance.id;
        final int factor = preferenceImportance.factor ?? 0;
        final int minimalMatch = preferenceImportance.minimalMatch;
        if (importanceId == null || factor == 0) {
          _debug += '${attribute.id} $importanceId\n';
        } else {
          if (attribute.status == AttributeExtra.STATUS_UNKNOWN) {
            if (_status ?? false) {
              _status = null;
            }
          } else {
            _debug +=
                '${attribute.id} $importanceId - match: ${attribute.match}\n';
            _score += attribute.match * factor;
            if (minimalMatch != null && attribute.match <= minimalMatch) {
              _status = false;
            }
          }
        }
      }
    }
  }

  final Product product;
  double _score = 0;
  bool _status = true;
  String _debug = '';

  double get score => _score;
  bool get status => _status;
  String get debug => _debug;

  static List<MatchedProduct> sort(
    final List<Product> products,
    final ProductPreferencesManager productPreferencesManager,
  ) {
    final List<MatchedProduct> result = <MatchedProduct>[];
    for (final Product product in products) {
      final MatchedProduct matchedProduct =
          MatchedProduct(product, productPreferencesManager);
      result.add(matchedProduct);
    }
    result.sort(
        (MatchedProduct a, MatchedProduct b) => b.score.compareTo(a.score));
    return result;
  }
}
