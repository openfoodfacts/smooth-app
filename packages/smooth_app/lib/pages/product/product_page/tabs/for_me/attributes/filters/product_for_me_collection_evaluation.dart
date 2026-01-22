import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/filters/product_for_me_collection.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Sort attributes into groups based on their evaluation.
final class AttributesEvaluationCollector implements ForMeAttributesFilter {
  final List<Attribute> goodMatches = <Attribute>[];
  final List<Attribute> averageMatches = <Attribute>[];
  final List<Attribute> badMatches = <Attribute>[];
  final List<Attribute> unknownMatches = <Attribute>[];

  @override
  void add(Attribute attribute) {
    final AttributeEvaluation evaluation = getAttributeEvaluation(attribute);
    switch (evaluation) {
      case AttributeEvaluation.VERY_GOOD:
        goodMatches.add(attribute);
      case AttributeEvaluation.GOOD:
        goodMatches.add(attribute);
      case AttributeEvaluation.NEUTRAL:
        averageMatches.add(attribute);
      case AttributeEvaluation.BAD:
        badMatches.add(attribute);
      case AttributeEvaluation.VERY_BAD:
        badMatches.add(attribute);
      case AttributeEvaluation.UNKNOWN:
        unknownMatches.add(attribute);
    }
  }

  List<Attribute> _byEvaluation(_AttributesEvaluation ev) {
    return switch (ev) {
      _AttributesEvaluation.good => goodMatches,
      _AttributesEvaluation.average => averageMatches,
      _AttributesEvaluation.bad => badMatches,
      _AttributesEvaluation.unknown => unknownMatches,
    };
  }

  List<_AttributesEvaluation> _sortedOrder() {
    final List<_AttributesEvaluation> list = List<_AttributesEvaluation>.from(
      _AttributesEvaluation.values,
    );

    list.sort((_AttributesEvaluation a, _AttributesEvaluation b) {
      final int lenA = _byEvaluation(a).length;
      final int lenB = _byEvaluation(b).length;
      return lenB.compareTo(lenA);
    });

    return list;
  }

  @override
  List<ForMeAttributesCollection> sortedGroups(
    AppLocalizations appLocalizations,
    SmoothColorsThemeExtension theme,
  ) {
    final List<_AttributesEvaluation> list = _sortedOrder();

    return list
        .map((_AttributesEvaluation ev) {
          final List<Attribute> attributes = _byEvaluation(ev);
          return ForMeAttributesCollection(
            name: ev.label(appLocalizations),
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

enum _AttributesEvaluation {
  good,
  average,
  bad,
  unknown;

  String label(AppLocalizations appLocalizations) {
    return switch (this) {
      _AttributesEvaluation.good =>
        appLocalizations.product_page_for_me_attributes_group_good_matches,
      _AttributesEvaluation.average =>
        appLocalizations.product_page_for_me_attributes_group_average_matches,
      _AttributesEvaluation.bad =>
        appLocalizations.product_page_for_me_attributes_group_bad_matches,
      _AttributesEvaluation.unknown =>
        appLocalizations.product_page_for_me_attributes_group_unknown_matches,
    };
  }
}
