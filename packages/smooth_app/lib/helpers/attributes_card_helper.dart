import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';

// TODO(Stephane): Evaluation should come directly from the BE.
enum AttributeEvaluation {
  UNKNOWN,
  VERY_BAD,
  BAD,
  NEUTRAL,
  GOOD,
  VERY_GOOD,
}

Color getBackgroundColor(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE),
      const HSLColor.fromAHSL(1, 0, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 30, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 60, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 90, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 120, 1, .9).toColor());
}

Color getTextColor(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Color.fromARGB(1, 75, 75, 75),
      const Color.fromARGB(1, 235, 87, 87),
      const Color.fromARGB(1, 242, 153, 74),
      const Color.fromARGB(255, 149, 116, 0),
      const Color.fromARGB(1, 133, 187, 47),
      const Color.fromARGB(1, 3, 129, 65));
}

Widget getAttributeDisplayIcon(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Text('❓  '),
      const Text('🔴  '),
      const Text('🟡  '),
      const Text('🟡  '),
      const Text('🟢  '),
      const Text('🟢  '));
}

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
  final int matchGrade = (attribute.match! / 20.0).ceil();
  switch (matchGrade) {
    case 0 | 1:
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

String? _getNovaDisplayTitle(final Attribute attribute) {
  // Note: This method is temporary, this field will come from Backend and it will be internationalized.
  return _attributeMatchComparison(attribute, null, 'Ultra processed',
      'Highly processed', 'Processed', 'Slightly processed', 'Unprocessed');
}

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
