import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatelessWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences,
  );

  final Attribute attribute;
  final ProductPreferences productPreferences;

  static const Map<String, MaterialColor> _ATTRIBUTE_IMPORTANCE_COLORS =
      <String, MaterialColor>{
    PreferenceImportance.ID_NOT_IMPORTANT: Colors.grey,
    PreferenceImportance.ID_IMPORTANT: Colors.green,
    PreferenceImportance.ID_VERY_IMPORTANT: Colors.orange,
    PreferenceImportance.ID_MANDATORY: Colors.red,
  };
  static const MaterialColor WARNING_COLOR = Colors.deepOrange;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothChip(
      materialColor: _ATTRIBUTE_IMPORTANCE_COLORS[
          productPreferences.getImportanceIdForAttributeId(attribute.id)],
      label: attribute.name,
      onPressed: () async {
        final String importanceId =
            productPreferences.getImportanceIdForAttributeId(attribute.id);
        final List<Widget> children = <Widget>[
          ListTile(
            leading: SvgCache(attribute.iconUrl, width: 40),
            title: Text(attribute.settingName),
          ),
        ];
        final AttributeGroup attributeGroup =
            productPreferences.getAttributeGroup(attribute.id);
        if (attributeGroup.warning != null) {
          children.add(
            Container(
              padding: const EdgeInsets.all(8.0),
              color: SmoothTheme.getColor(
                colorScheme,
                WARNING_COLOR,
                ColorDestination.BUTTON_BACKGROUND,
              ),
              width: double.infinity,
              child: Text(
                attributeGroup.warning,
                style: TextStyle(
                  color: SmoothTheme.getColor(
                    colorScheme,
                    WARNING_COLOR,
                    ColorDestination.BUTTON_FOREGROUND,
                  ),
                ),
              ),
            ),
          );
        }
        for (final String item in productPreferences.importanceIds) {
          final Color tileColor = _ATTRIBUTE_IMPORTANCE_COLORS[item] == null
              ? null
              : SmoothTheme.getColor(
                  colorScheme,
                  _ATTRIBUTE_IMPORTANCE_COLORS[item],
                  ColorDestination.SURFACE_BACKGROUND,
                );
          children.add(
            RadioListTile<String>(
              tileColor: tileColor,
              value: item,
              groupValue: importanceId,
              title: Text(productPreferences
                  .getPreferenceImportanceFromImportanceId(item)
                  .name),
              onChanged: (final String value) =>
                  Navigator.pop<String>(context, value),
            ),
          );
        }
        final String result = await showDialog<String>(
          context: context,
          builder: (final BuildContext context) => SmoothAlertDialog(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
            actions: <SmoothSimpleButton>[
              SmoothSimpleButton(
                text: appLocalizations.cancel,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        if (result == null) {
          return;
        }
        productPreferences.setImportance(attribute.id, result);
      },
    );
  }
}
