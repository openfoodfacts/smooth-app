import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
    PreferenceImportance.ID_NOT_IMPORTANT: PRIMARY_GREY_COLOR,
    PreferenceImportance.ID_IMPORTANT: PRIMARY_BLUE_COLOR,
    PreferenceImportance.ID_MANDATORY: RED_COLOR,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final String importanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id!);
    const double horizontalPadding = LARGE_SPACE;
    final double screenWidth =
        MediaQuery.of(context).size.width - 2 * horizontalPadding;
    final TextStyle styleLabel = themeData.textTheme.bodyMedium!;
    final TextStyle styleButton = themeData.textTheme.headline4!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: screenWidth * .45,
            child: Text(attribute.settingName!, style: styleLabel),
          ),
          SizedBox(
            width: screenWidth * .45,
            child: ElevatedButton(
              child: Text(
                productPreferences
                    .getPreferenceImportanceFromImportanceId(importanceId)!
                    .name!,
                style: styleButton.copyWith(color: Colors.white),
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
