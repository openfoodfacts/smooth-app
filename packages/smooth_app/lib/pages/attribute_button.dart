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
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

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
    PreferenceImportance.ID_NOT_IMPORTANT: Icons.remove,
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
    final bool important =
        importanceId != PreferenceImportance.ID_NOT_IMPORTANT;
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(themeProvider);
    final Color strongBackgroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_BACKGROUND,
    );
    final Color strongForegroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_FOREGROUND,
    );
    final Color foregroundColor = !important ? null : strongForegroundColor;
    final Color backgroundColor = !important ? null : strongBackgroundColor;
    return ListTile(
      tileColor: backgroundColor,
      title: Text(attribute.name, style: TextStyle(color: foregroundColor)),
      leading: SvgCache(attribute.iconUrl, width: 40),
      trailing: Icon(_IMPORTANCE_ICONS[importanceId], color: foregroundColor),
      onTap: () async {
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
          final bool important = item != PreferenceImportance.ID_NOT_IMPORTANT;
          final Color foregroundColor =
              !important ? null : strongForegroundColor;
          final Color backgroundColor =
              !important ? null : strongBackgroundColor;
          children.add(
            ListTile(
              tileColor: backgroundColor,
              leading: importanceId == item
                  ? Icon(Icons.radio_button_checked, color: foregroundColor)
                  : Icon(Icons.radio_button_unchecked, color: foregroundColor),
              title: Text(
                productPreferences
                    .getPreferenceImportanceFromImportanceId(item)
                    .name,
                style: TextStyle(color: foregroundColor),
              ),
              onTap: () => Navigator.pop<String>(context, item),
              trailing: Icon(_IMPORTANCE_ICONS[item], color: foregroundColor),
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
