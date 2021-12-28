import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';

/// Vertical list of radio buttons used to set the importance of an attribute.
///
/// To be used in an alert dialog because it exits with `Navigator.pop`
class AttributeDialog extends StatelessWidget {
  const AttributeDialog(
    this.attributeId,
    this.productPreferences,
  );

  final String attributeId;
  final ProductPreferences productPreferences;

  /// Importance ids we're dealing with in the project
  ///
  /// Note: for UX reasons we ignore "very important"
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/671
  static const List<String> _importanceIds = <String>[
    PreferenceImportance.ID_NOT_IMPORTANT,
    PreferenceImportance.ID_IMPORTANT,
    PreferenceImportance.ID_MANDATORY,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final Attribute? attribute =
        productPreferences.getReferenceAttribute(attributeId);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String importanceId =
        productPreferences.getImportanceIdForAttributeId(attributeId);
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(themeProvider);
    final Color? strongBackgroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_BACKGROUND,
    );
    final Color? strongForegroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_FOREGROUND,
    );
    final List<Widget> children = <Widget>[
      ListTile(
        leading: SvgCache(attribute!.iconUrl, width: 40),
        title: Text(attribute.settingName!),
      ),
    ];
    final AttributeGroup attributeGroup =
        productPreferences.getAttributeGroup(attributeId);
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
            attributeGroup.warning!,
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

    for (final String item in _importanceIds) {
      final Color? foregroundColor =
          getForegroundColor(strongForegroundColor!, item);
      children.add(
        ListTile(
          tileColor: getBackgroundColor(strongBackgroundColor!, item),
          leading: importanceId == item
              ? Icon(Icons.radio_button_checked, color: foregroundColor)
              : Icon(Icons.radio_button_unchecked, color: foregroundColor),
          title: Text(
            productPreferences
                .getPreferenceImportanceFromImportanceId(item)!
                .name!,
            style: TextStyle(color: foregroundColor),
          ),
          onTap: () {
            productPreferences.setImportance(attribute.id!, item);
            Navigator.pop(context);
          },
          trailing: getIcon(item, foregroundColor),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
