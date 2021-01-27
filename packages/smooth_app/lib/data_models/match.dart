import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/user_preferences.dart';

/// cf. https://github.com/openfoodfacts/smooth-app/issues/39
class Match {
  Match(
    final Product product,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) {
    final List<AttributeGroup> attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      _status = null;
      return;
    }
    for (final AttributeGroup group in attributeGroups) {
      for (final Attribute attribute in group.attributes) {
        final PreferencesValue preferencesValue = userPreferencesModel
            .getPreferencesValue(attribute.id, userPreferences);
        final String value = preferencesValue.id;
        final int factor = preferencesValue.factor ?? 0;
        final int minimalMatch = preferencesValue.minimalMatch;
        bool currentAttributeStatus = true;
        if (value == null || factor == 0) {
          _debug += '${attribute.id} $value\n';
        } else {
          if (attribute.status == _UNKNOWN_STATUS) {
            currentAttributeStatus = null;
            if (_status ?? false) {
              _status = null;
            }
          } else {
            _debug += '${attribute.id} $value - match: ${attribute.match}\n';
            _score += attribute.match * factor;
            if (minimalMatch != null && attribute.match <= minimalMatch) {
              currentAttributeStatus = false;
              _status = false;
            }
          }
        }
        _attributeStatus[attribute.id] = currentAttributeStatus;
      }
    }
  }

  static const String _UNKNOWN_STATUS = 'unknown';

  final Map<String, bool> _attributeStatus = <String, bool>{};
  double _score = 0;
  bool _status = true;
  String _debug = '';

  double get score => _score;
  bool get status => _status;
  String get debug => _debug;

  bool getAttributeStatus(final String attributeId) =>
      _attributeStatus[attributeId];

  static List<RankedProduct> sort(
    final List<Product> products,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) {
    final List<RankedProduct> result = <RankedProduct>[];
    for (final Product product in products) {
      final Match match = Match(product, userPreferences, userPreferencesModel);
      result.add(RankedProduct(product: product, match: match));
    }
    result.sort((RankedProduct a, RankedProduct b) =>
        b.match.score.compareTo(a.match.score));
    return result;
  }
}
