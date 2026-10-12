import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/filters/product_for_me_collection.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Sort attributes into groups based on their importance level.
final class AttributesImportanceCollector implements ForMeAttributesFilter {
  AttributesImportanceCollector(this.preferences);

  final ProductPreferences preferences;

  final List<Attribute> mandatoryAttributes = <Attribute>[];
  final List<Attribute> veryImportantAttributes = <Attribute>[];
  final List<Attribute> importantAttributes = <Attribute>[];
  final List<Attribute> notImportantAttributes = <Attribute>[];

  @override
  void add(Attribute attribute) {
    if (attribute.id == null) {
      return;
    }

    final String importanceId = preferences.getImportanceIdForAttributeId(
      attribute.id!,
    );

    switch (importanceId) {
      case PreferenceImportance.ID_MANDATORY:
        mandatoryAttributes.add(attribute);
      case PreferenceImportance.ID_VERY_IMPORTANT:
        veryImportantAttributes.add(attribute);
      case PreferenceImportance.ID_IMPORTANT:
        importantAttributes.add(attribute);
      case PreferenceImportance.ID_NOT_IMPORTANT:
        notImportantAttributes.add(attribute);
      default:
        notImportantAttributes.add(attribute);
    }
  }

  List<Attribute> _byImportance(_AttributesImportance importance) {
    return switch (importance) {
      _AttributesImportance.mandatory => mandatoryAttributes,
      _AttributesImportance.veryImportant => veryImportantAttributes,
      _AttributesImportance.important => importantAttributes,
      _AttributesImportance.notImportant => notImportantAttributes,
    };
  }

  List<_AttributesImportance> _sortedOrder() {
    // Return in order from most important to least important
    return List<_AttributesImportance>.from(_AttributesImportance.values);
  }

  @override
  List<ForMeAttributesCollection> sortedGroups(
    AppLocalizations appLocalizations,
    SmoothColorsThemeExtension theme,
  ) {
    return _sortedOrder()
        .map((_AttributesImportance importance) {
          final List<Attribute> attributes = List<Attribute>.from(
            _byImportance(importance),
          );

          attributes.sort(
            (Attribute a, Attribute b) =>
                (a.match ?? 0.0).compareTo(b.match ?? 0.0),
          );

          return ForMeAttributesCollection(
            name: importance.label(preferences),
            attributes: attributes,
          );
        })
        .where(
          (ForMeAttributesCollection collection) =>
              collection.attributes.isNotEmpty,
        )
        .toList(growable: false);
  }
}

enum _AttributesImportance {
  mandatory,
  veryImportant,
  important,
  notImportant;

  String label(ProductPreferences preferences) {
    final String importanceId = switch (this) {
      _AttributesImportance.mandatory => PreferenceImportance.ID_MANDATORY,
      _AttributesImportance.veryImportant =>
        PreferenceImportance.ID_VERY_IMPORTANT,
      _AttributesImportance.important => PreferenceImportance.ID_IMPORTANT,
      _AttributesImportance.notImportant =>
        PreferenceImportance.ID_NOT_IMPORTANT,
    };

    return preferences
            .getPreferenceImportanceFromImportanceId(importanceId)
            ?.name ??
        importanceId;
  }
}
