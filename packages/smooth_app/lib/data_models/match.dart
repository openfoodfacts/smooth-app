import 'package:openfoodfacts/model/AttributeGroups.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:openfoodfacts/model/Product.dart';

/// cf. https://github.com/openfoodfacts/smooth-app/issues/39
class Match {
  Match(final Product product, final UserPreferencesModel model) {
    final AttributeGroups attributeGroups = product.attributeGroups;
    if (attributeGroups == null) {
      _status = null;
      return;
    }
    for (final List<Attribute> attributes in attributeGroups.groups.values) {
      for (final Attribute attribute in attributes) {
        final String variable = attribute.id;
        final PreferencesValue preferencesValue =
            model.getPreferencesValue(variable);
        final String value = preferencesValue.id;
        _attributes[value] ??= <Attribute>[];
        _attributes[value].add(attribute);
        final int factor = preferencesValue.factor ?? 0;
        final int minimalMatch = preferencesValue.minimalMatch;
        if (value == null || factor == 0) {
          _debug += '$variable $value\n';
        } else {
          if (attribute.status == _UNKNOWN_STATUS) {
            if (_status) {
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
}
