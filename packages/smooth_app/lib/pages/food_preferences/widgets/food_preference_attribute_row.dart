import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
import 'package:smooth_app/pages/food_preferences/widgets/unwanted_ingredients_input.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';

class FoodPreferenceAttributeRow extends StatelessWidget {
  const FoodPreferenceAttributeRow({
    required this.attribute,
    required this.pendingPreferences,
    super.key,
  });

  final Attribute attribute;
  final PendingPreferences pendingPreferences;

  @override
  Widget build(BuildContext context) {
    final String? attributeId = attribute.id;
    if (attributeId == null) {
      return EMPTY_WIDGET;
    }
    final String title = attribute.settingName ?? attribute.name ?? '';

    final List<String>? values = attribute.values?.toList();
    final String offImportanceId =
        values?.elementAtOrNull(0) ?? PreferenceImportance.ID_NOT_IMPORTANT;
    final String onImportanceId =
        values?.elementAtOrNull(1) ?? PreferenceImportance.ID_MANDATORY;

    final String currentImportanceId = pendingPreferences
        .getImportanceIdForAttributeId(attributeId);
    final bool isEnabled = currentImportanceId == onImportanceId;

    final bool isUnwantedIngredients =
        attributeId == Attribute.ATTRIBUTE_UNWANTED_INGREDIENTS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: () {
            pendingPreferences.setImportance(
              attributeId,
              isEnabled ? offImportanceId : onImportanceId,
            );
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
              vertical: VERY_SMALL_SPACE,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: LARGE_SPACE,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SmoothSwitch(
                  value: isEnabled,
                  onChanged: (bool value) {
                    pendingPreferences.setImportance(
                      attributeId,
                      value ? onImportanceId : offImportanceId,
                    );
                  },
                  size: const Size(42.0, 26.0),
                ),
              ],
            ),
          ),
        ),
        if (isUnwantedIngredients && isEnabled)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              start: SMALL_SPACE,
              end: SMALL_SPACE,
            ),
            child: UnwantedIngredientsInput(
              pendingPreferences: pendingPreferences,
            ),
          ),
      ],
    );
  }
}
