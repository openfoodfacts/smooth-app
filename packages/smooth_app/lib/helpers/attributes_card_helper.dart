import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

// TODO(Stephane): Evaluation should come directly from the BE.
enum AttributeEvaluation {
  UNKNOWN,
  VERY_BAD,
  BAD,
  NEUTRAL,
  GOOD,
  VERY_GOOD,
}

Widget getAttributeDisplayIcon(final Attribute attribute) => Padding(
      padding: const EdgeInsets.only(right: VERY_SMALL_SPACE),
      child: _attributeMatchComparison(
        attribute,
        const Icon(CupertinoIcons.question, color: RED_COLOR),
        const Icon(Icons.lens, color: RED_COLOR),
        const Icon(Icons.lens, color: LIGHT_ORANGE_COLOR),
        const Icon(Icons.lens, color: LIGHT_ORANGE_COLOR),
        const Icon(Icons.lens, color: LIGHT_GREEN_COLOR),
        const Icon(Icons.lens, color: LIGHT_GREEN_COLOR),
      ),
    );

bool isMatchAvailable(Attribute attribute) {
  return attribute.status == Attribute.STATUS_KNOWN && attribute.match != null;
}

AttributeEvaluation getAttributeEvaluation(Attribute attribute) {
  if (!isMatchAvailable(attribute)) {
    return AttributeEvaluation.UNKNOWN;
  }
  // Note: Match evaluation is temporary, it should come from the server,
  // currently it's computed as:
  // 0-20: Very Bad
  // 21-40: Bad
  // 41-60: Neutral
  // 61-80: Good
  // 81-100: Very good
  // > 100: Unknown
  final int matchGrade = (attribute.match! / 20.0).ceil();
  switch (matchGrade) {
    case 0:
    case 1:
      return AttributeEvaluation.VERY_BAD;
    case 2:
      return AttributeEvaluation.BAD;
    case 3:
      return AttributeEvaluation.NEUTRAL;
    case 4:
      return AttributeEvaluation.GOOD;
    case 5:
      return AttributeEvaluation.VERY_GOOD;
    default:
      // Unknown Match score > 100
      return AttributeEvaluation.UNKNOWN;
  }
}

String? getDisplayTitle(final Attribute attribute) {
  if (attribute.id != Attribute.ATTRIBUTE_NOVA) {
    return attribute.title;
  }
  return _getNovaDisplayTitle(attribute);
}

String? _getNovaDisplayTitle(final Attribute attribute) =>
    attribute.descriptionShort;

/// Compares the match score from [attribute] with various thresholds and returns appropriate result.
T _attributeMatchComparison<T>(
    final Attribute attribute,
    T invalidAttributeResult,
    T lowestMatchResult,
    T lowMatchResult,
    T midMatchResult,
    T highMatchResult,
    T highestMatchResult) {
  final AttributeEvaluation evaluation = getAttributeEvaluation(attribute);
  switch (evaluation) {
    case AttributeEvaluation.UNKNOWN:
      return invalidAttributeResult;
    case AttributeEvaluation.VERY_BAD:
      return lowestMatchResult;
    case AttributeEvaluation.BAD:
      return lowMatchResult;
    case AttributeEvaluation.NEUTRAL:
      return midMatchResult;
    case AttributeEvaluation.GOOD:
      return highMatchResult;
    case AttributeEvaluation.VERY_GOOD:
      return highestMatchResult;
  }
}
