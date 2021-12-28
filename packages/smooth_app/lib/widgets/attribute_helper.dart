import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';

// Common values and methods for attribute display

const MaterialColor WARNING_COLOR = Colors.deepOrange;

const Map<String, String> _IMPORTANCE_SVG_ASSETS = <String, String>{
  PreferenceImportance.ID_IMPORTANT: 'assets/data/important.svg',
  PreferenceImportance.ID_MANDATORY: 'assets/data/mandatory.svg',
};

const Map<String, double> _IMPORTANCE_OPACITIES = <String, double>{
  PreferenceImportance.ID_IMPORTANT: .5,
  PreferenceImportance.ID_MANDATORY: 1,
};

Widget? getIcon(final String importanceId, final Color? color) {
  final String? svgAsset = _IMPORTANCE_SVG_ASSETS[importanceId];
  if (svgAsset == null) {
    return null;
  }
  return SvgPicture.asset(svgAsset, color: color, height: 32);
}

Color? getBackgroundColor(
  final Color strongBackgroundColor,
  final String importanceId,
) {
  final double? opacity = _IMPORTANCE_OPACITIES[importanceId];
  if (opacity == null) {
    return null;
  }
  return strongBackgroundColor.withOpacity(opacity);
}

Color? getForegroundColor(
  final Color strongForegroundColor,
  final String importanceId,
) =>
    importanceId == PreferenceImportance.ID_NOT_IMPORTANT
        ? null
        : strongForegroundColor;
