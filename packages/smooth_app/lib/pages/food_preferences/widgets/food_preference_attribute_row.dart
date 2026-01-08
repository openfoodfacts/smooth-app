import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
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
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final String title = attribute.settingName ?? attribute.name ?? '';

    final bool isEnabled = pendingPreferences.isAttributeEnabled(attributeId);

    return InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: () {
        pendingPreferences.toggleAttribute(attributeId);
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SmoothSwitch(
              value: isEnabled,
              onChanged: (bool value) {
                pendingPreferences.toggleAttribute(attributeId);
              },
              size: const Size(42.0, 26.0),
            ),
          ],
        ),
      ),
    );
  }
}
