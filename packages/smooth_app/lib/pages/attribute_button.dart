import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  static const MaterialColor WARNING_COLOR = Colors.deepOrange;
  static const Map<String, IconData> _IMPORTANCE_ICONS = <String, IconData>{
    PreferenceImportance.ID_NOT_IMPORTANT: null,
    PreferenceImportance.ID_IMPORTANT: CupertinoIcons.star,
    PreferenceImportance.ID_VERY_IMPORTANT: CupertinoIcons.star_lefthalf_fill,
    PreferenceImportance.ID_MANDATORY: CupertinoIcons.star_fill,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String importanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id);
    return SmoothChip(
      label: attribute.name,
      iconData: _IMPORTANCE_ICONS[importanceId],
      onPressed: () async {
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
          children.add(
            ListTile(
              leading: importanceId == item
                  ? const Icon(Icons.radio_button_checked)
                  : const Icon(Icons.radio_button_unchecked),
              title: Text(productPreferences
                  .getPreferenceImportanceFromImportanceId(item)
                  .name),
              onTap: () => Navigator.pop<String>(context, item),
              trailing: Icon(_IMPORTANCE_ICONS[item]),
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
