import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatelessWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences,
  );

  final Attribute attribute;
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

  static const MaterialColor WARNING_COLOR = Colors.deepOrange;

  static const Map<String, String> _IMPORTANCE_SVG_ASSETS = <String, String>{
    PreferenceImportance.ID_IMPORTANT: 'assets/data/important.svg',
    PreferenceImportance.ID_MANDATORY: 'assets/data/mandatory.svg',
  };

  static const Map<String, double> _IMPORTANCE_OPACITIES = <String, double>{
    PreferenceImportance.ID_IMPORTANT: .5,
    PreferenceImportance.ID_MANDATORY: 1,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    String importanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id!);
    // We switch from 4 to 3 choices: very important is downgraded to important
    if (importanceId == PreferenceImportance.ID_VERY_IMPORTANT) {
      importanceId = PreferenceImportance.ID_IMPORTANT;
    }
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
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
    final Color? foregroundColor =
        _getForegroundColor(strongForegroundColor!, importanceId);
    return ListTile(
      tileColor: _getBackgroundColor(strongBackgroundColor!, importanceId),
      title: Text(attribute.name!, style: TextStyle(color: foregroundColor)),
      leading: SvgCache(attribute.iconUrl, width: 40),
      trailing: _getIcon(importanceId, foregroundColor),
      onTap: () async => onTap(
        context: context,
        attributeId: attribute.id!,
        productPreferences: productPreferences,
        themeProvider: themeProvider,
      ),
    );
  }

  static Future<void> onTap({
    required final BuildContext context,
    required final String attributeId,
    required final ProductPreferences productPreferences,
    required final ThemeProvider themeProvider,
  }) async {
    final Attribute? attribute =
        productPreferences.getReferenceAttribute(attributeId);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
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
          _getForegroundColor(strongForegroundColor!, item);
      children.add(
        ListTile(
          tileColor: _getBackgroundColor(strongBackgroundColor!, item),
          leading: importanceId == item
              ? Icon(Icons.radio_button_checked, color: foregroundColor)
              : Icon(Icons.radio_button_unchecked, color: foregroundColor),
          title: Text(
            productPreferences
                .getPreferenceImportanceFromImportanceId(item)!
                .name!,
            style: TextStyle(color: foregroundColor),
          ),
          onTap: () => Navigator.pop<String>(context, item),
          trailing: _getIcon(item, foregroundColor),
        ),
      );
    }
    final String? result = await showDialog<String>(
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
    productPreferences.setImportance(attributeId, result);
  }

  static Widget? _getIcon(final String importanceId, final Color? color) {
    final String? svgAsset = _IMPORTANCE_SVG_ASSETS[importanceId];
    if (svgAsset == null) {
      return null;
    }
    return SvgPicture.asset(svgAsset, color: color, height: 32);
  }

  static Color? _getBackgroundColor(
    final Color strongBackgroundColor,
    final String importanceId,
  ) {
    final double? opacity = _IMPORTANCE_OPACITIES[importanceId];
    if (opacity == null) {
      return null;
    }
    return strongBackgroundColor.withOpacity(opacity);
  }

  static Color? _getForegroundColor(
    final Color strongForegroundColor,
    final String importanceId,
  ) =>
      importanceId == PreferenceImportance.ID_NOT_IMPORTANT
          ? null
          : strongForegroundColor;
}
