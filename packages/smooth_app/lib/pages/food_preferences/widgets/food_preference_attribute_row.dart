import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';

class FoodPreferenceAttributeRow extends StatelessWidget {
  const FoodPreferenceAttributeRow({
    required this.attribute,
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });

  final Attribute attribute;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String title = attribute.settingName ?? attribute.name ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          onChanged: onChanged,
          size: const Size(42.0, 26.0),
        ),
      ],
    );
  }
}
