import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/attribute_dialog.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';
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
        getForegroundColor(strongForegroundColor!, importanceId);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return ListTile(
      tileColor: getBackgroundColor(strongBackgroundColor!, importanceId),
      title: Text(attribute.name!, style: TextStyle(color: foregroundColor)),
      leading: SvgCache(attribute.iconUrl, width: 40),
      trailing: getIcon(importanceId, foregroundColor),
      onTap: () async => showDialog<String>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          body: AttributeDialog(attribute.id!, productPreferences),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: appLocalizations.cancel,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
