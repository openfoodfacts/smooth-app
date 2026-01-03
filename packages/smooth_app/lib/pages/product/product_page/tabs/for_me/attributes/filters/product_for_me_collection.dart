import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

enum ForMeAttributesFilterType {
  importance(_IMPORTANCE_KEY),
  evaluation(_EVALUATION_KEY);

  const ForMeAttributesFilterType(this.key);

  static const String _IMPORTANCE_KEY = 'importance';
  static const String _EVALUATION_KEY = 'evaluation';

  final String key;

  static ForMeAttributesFilterType get defaultValue =>
      ForMeAttributesFilterType.importance;

  static ForMeAttributesFilterType fromKey(String key) {
    switch (key) {
      case _IMPORTANCE_KEY:
        return ForMeAttributesFilterType.importance;
      case _EVALUATION_KEY:
        return ForMeAttributesFilterType.evaluation;
      default:
        return throw Exception('Unknown key $key');
    }
  }
}

abstract interface class ForMeAttributesFilter {
  void add(Attribute attribute);

  List<ForMeAttributesCollection> sortedGroups(
    AppLocalizations appLocalizations,
    SmoothColorsThemeExtension theme,
  );
}

class ForMeAttributesCollection {
  ForMeAttributesCollection({required this.name, required this.attributes});

  final String name;
  final List<Attribute> attributes;
}
