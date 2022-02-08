import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatelessWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences,
  );

  final Attribute attribute;
  final ProductPreferences productPreferences;

  static const Map<String, String> _nextValues = <String, String>{
    PreferenceImportance.ID_NOT_IMPORTANT: PreferenceImportance.ID_IMPORTANT,
    PreferenceImportance.ID_IMPORTANT: PreferenceImportance.ID_MANDATORY,
    PreferenceImportance.ID_MANDATORY: PreferenceImportance.ID_NOT_IMPORTANT,
  };

  static const Map<String, Color> _colors = <String, Color>{
    PreferenceImportance.ID_NOT_IMPORTANT: Color(0xFF666666),
    PreferenceImportance.ID_IMPORTANT: Colors.blue,
    PreferenceImportance.ID_MANDATORY: Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    String importanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id!);
    // We switch from 4 to 3 choices: very important is downgraded to important
    if (importanceId == PreferenceImportance.ID_VERY_IMPORTANT) {
      importanceId = PreferenceImportance.ID_IMPORTANT;
    }
    const double horizontalPadding = LARGE_SPACE;
    final double screenWidth =
        MediaQuery.of(context).size.width - 2 * horizontalPadding;
    final TextStyle style = themeData.textTheme.headline3!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: screenWidth * .45,
            child: Text(attribute.name!, style: style),
          ),
          SizedBox(
            width: screenWidth * .45,
            child: ElevatedButton(
              child: Text(
                productPreferences
                    .getPreferenceImportanceFromImportanceId(importanceId)!
                    .name!,
                style: style.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: _colors[importanceId],
                onPrimary: Colors.white,
              ),
              onPressed: () async => productPreferences.setImportance(
                  attribute.id!, _nextValues[importanceId]!),
            ),
          ),
        ],
      ),
    );
  }
}
