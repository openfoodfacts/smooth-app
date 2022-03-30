import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_manager.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'attributes_card_helper.dart';

/// Match and score of a [Product] vs. Preferences
///
/// cf. https://github.com/openfoodfacts/smooth-app/issues/39
/// Inspiration taken from off-dart's MatchedProduct.dart

enum MatchedProductStatus {
  YES,
  NO,
  UNKNOWN,
}

abstract class MatchedProduct {
  MatchedProduct(this.product);

  static MatchedProduct getMatchedProduct(
    final Product product,
    final ProductPreferencesManager productPreferencesManager,
    final UserPreferences userPreferences,
  ) =>
      userPreferences.getFlag(
                  UserPreferencesDevMode.userPreferencesFlagLenientMatching) ??
              false
          ? _StrongMatchedProduct(product, productPreferencesManager)
          : _LenientMatchedProduct(product, productPreferencesManager);

  final Product product;
  double get score;
  MatchedProductStatus? get status;

  static List<MatchedProduct> sort(
    final List<Product> products,
    final ProductPreferencesManager productPreferencesManager,
    final UserPreferences userPreferences,
  ) {
    final List<MatchedProduct> result = <MatchedProduct>[];
    for (final Product product in products) {
      final MatchedProduct matchedProduct = MatchedProduct.getMatchedProduct(
        product,
        productPreferencesManager,
        userPreferences,
      );
      result.add(matchedProduct);
    }
    result.sort(
        (MatchedProduct a, MatchedProduct b) => b.score.compareTo(a.score));
    return result;
  }
}

/// Original version (monsieurtanuki)
class _StrongMatchedProduct extends MatchedProduct {
  _StrongMatchedProduct(
    final Product product,
    final ProductPreferencesManager productPreferencesManager,
  ) : super(product) {
    final List<AttributeGroup>? attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      _status = null;
      return;
    }
    _status = MatchedProductStatus.YES;
    for (final AttributeGroup group in attributeGroups) {
      if (group.attributes != null) {
        for (final Attribute attribute in group.attributes!) {
          final PreferenceImportance? preferenceImportance =
              productPreferencesManager.getPreferenceImportanceFromImportanceId(
            productPreferencesManager.getImportanceIdForAttributeId(
              attribute.id!,
            ),
          );
          if (preferenceImportance != null) {
            final String? importanceId = preferenceImportance.id;
            final int factor = preferenceImportance.factor ?? 0;
            final int? minimalMatch = preferenceImportance.minimalMatch;
            if (importanceId == null || factor == 0) {
              _debug += '${attribute.id} $importanceId\n';
            } else {
              if (attribute.status == Attribute.STATUS_UNKNOWN) {
                if (_status == MatchedProductStatus.YES) {
                  _status = MatchedProductStatus.UNKNOWN;
                }
              } else {
                _debug +=
                    '${attribute.id} $importanceId - match: ${attribute.match}\n';
                _score += (attribute.match ?? 0) * factor;
                if (minimalMatch != null &&
                    (attribute.match ?? 0) <= minimalMatch) {
                  _status = MatchedProductStatus.NO;
                }
              }
            }
          }
        }
      }
    }
  }

  double _score = 0;
  MatchedProductStatus? _status;
  String _debug = '';

  @override
  double get score => _score;
  @override
  MatchedProductStatus? get status => _status;
  String get debug => _debug;
}

const Map<String, int> _attributeImportanceWeight = <String, int>{
  PreferenceImportance.ID_MANDATORY: 4,
  PreferenceImportance.ID_IMPORTANT: 1,
  PreferenceImportance.ID_NOT_IMPORTANT: 0,
};

/// Lenient version (jasmeet0817) (found back in #1046)
class _LenientMatchedProduct extends MatchedProduct {
  _LenientMatchedProduct(
    final Product product,
    final ProductPreferencesManager productPreferencesManager,
  ) : super(product) {
    _score = 0.0;
    int numAttributesComputed = 0;
    if (product.attributeGroups != null) {
      for (final AttributeGroup group in product.attributeGroups!) {
        if (group.attributes != null) {
          for (final Attribute attribute in group.attributes!) {
            final String importanceLevel = productPreferencesManager
                .getImportanceIdForAttributeId(attribute.id!);
            // Check whether any mandatory attribute is incompatible
            if (importanceLevel == PreferenceImportance.ID_MANDATORY &&
                getAttributeEvaluation(attribute) ==
                    AttributeEvaluation.VERY_BAD) {
              _status = MatchedProductStatus.NO;
              return;
            }
            if (!_attributeImportanceWeight.containsKey(importanceLevel)) {
              // Unknown attribute importance level. (This should ideally never happen).
              continue;
            }
            if (_attributeImportanceWeight[importanceLevel] == 0.0) {
              // Skip attributes that are not important
              continue;
            }
            if (!isMatchAvailable(attribute)) {
              continue;
            }
            _score +=
                attribute.match! * _attributeImportanceWeight[importanceLevel]!;
            numAttributesComputed++;
          }
        }
      }
    }
    if (numAttributesComputed == 0) {
      _status = MatchedProductStatus.NO;
      return;
    }
    _status = MatchedProductStatus.YES;
  }

  late double _score;
  MatchedProductStatus? _status;

  @override
  double get score => _score;
  @override
  MatchedProductStatus? get status => _status;
}
