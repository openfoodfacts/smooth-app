import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';

const int _LOWEST_MATCH_SCORE_THRESHOLD = 20;
const int _LOW_MATCH_SCORE_THRESHOLD = 40;
const int _MID_MATCH_SCORE_THRESHOLD = 60;
const int _HIGH_MATCH_SCORE_THRESHOLD = 80;

Color getBackgroundColor(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE),
      const HSLColor.fromAHSL(1, 0, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 30, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 60, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 90, 1, .9).toColor(),
      const HSLColor.fromAHSL(1, 120, 1, .9).toColor()) as Color;
}

Color getTextColor(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Color.fromARGB(1, 75, 75, 75),
      const Color.fromARGB(1, 235, 87, 87),
      const Color.fromARGB(1, 242, 153, 74),
      const Color.fromARGB(255, 149, 116, 0),
      const Color.fromARGB(1, 133, 187, 47),
      const Color.fromARGB(1, 3, 129, 65)) as Color;
}

Widget getAttributeDisplayIcon(final Attribute attribute) {
  return _attributeMatchComparison(
      attribute,
      const Text('ℹ️  '),
      const Text('💔  '),
      const Text('🍂  '),
      const Text('🌻  '),
      const Text('🌱  '),
      const Text('💚  ')) as Widget;
}

String? getDisplayTitle(final Attribute attribute) {
  if (attribute.id != Attribute.ATTRIBUTE_NOVA) {
    return attribute.title;
  }
  return _getNovaDisplayTitle(attribute);
}

String? _getNovaDisplayTitle(final Attribute attribute) {
  // Note: This method is temporary, this field will come from Backend and it will be internationalized.
  return _attributeMatchComparison(
      attribute,
      null,
      'Ultra processed',
      'Highly processed',
      'Processed',
      'Slightly processed',
      'Unprocessed') as String?;
}

/// Compares the match score from [attribute] with various thresholds and returns appropriate result.
dynamic _attributeMatchComparison(
    final Attribute attribute,
    dynamic invalidAttributeResult,
    dynamic lowestMatchResult,
    dynamic lowMatchResult,
    dynamic midMatchResult,
    dynamic highMatchResult,
    dynamic highestMatchResult) {
  if (attribute.status != Attribute.STATUS_KNOWN || attribute.match == null) {
    return invalidAttributeResult;
  }
  if (attribute.match! <= _LOWEST_MATCH_SCORE_THRESHOLD) {
    return lowestMatchResult;
  }
  if (attribute.match! <= _LOW_MATCH_SCORE_THRESHOLD) {
    return lowMatchResult;
  }
  if (attribute.match! <= _MID_MATCH_SCORE_THRESHOLD) {
    return midMatchResult;
  }
  if (attribute.match! <= _HIGH_MATCH_SCORE_THRESHOLD) {
    return highMatchResult;
  }
  return highestMatchResult;
}
