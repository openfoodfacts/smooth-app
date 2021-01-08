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
        final String variable = attribute.id;
        final PreferencesValue preferencesValue =
            userPreferencesModel.getPreferencesValue(variable, userPreferences);
        final String value = preferencesValue.id;
        _attributes[value] ??= <Attribute>[];
        _attributes[value].add(attribute);
        final int factor = preferencesValue.factor ?? 0;
        final int minimalMatch = preferencesValue.minimalMatch;
        if (value == null || factor == 0) {
          _debug += '$variable $value\n';
        } else {
          if (attribute.status == _UNKNOWN_STATUS) {
            if (_status ?? false) {
              _status = null;
            }
          } else {
            _debug += '$variable $value - match: ${attribute.match}\n';
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

  double _score = 0;
  bool _status = true;
  String _debug = '';
  final Map<String, List<Attribute>> _attributes = <String, List<Attribute>>{};

  double get score => _score;
  bool get status => _status;
  String get debug => _debug;
  Map<String, List<Attribute>> get attributes => _attributes;

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
