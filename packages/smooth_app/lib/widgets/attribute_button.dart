import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatelessWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences,
  );

  final Attribute attribute;
  final ProductPreferences productPreferences;

  static const List<String> _importanceIds = <String>[
    PreferenceImportance.ID_NOT_IMPORTANT,
    PreferenceImportance.ID_IMPORTANT,
    PreferenceImportance.ID_VERY_IMPORTANT,
    PreferenceImportance.ID_MANDATORY,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final IconThemeData iconThemeData = IconTheme.of(context);
    final String currentImportanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id!);
    const double horizontalPadding = LARGE_SPACE;
    final double widgetWidth =
        MediaQuery.of(context).size.width - 2 * horizontalPadding;
    final double importanceWidth = widgetWidth / 4;
    final TextStyle style = themeData.textTheme.headline3!;
    final String? info = attribute.settingNote;
    final List<Widget> children = <Widget>[];
    for (final String importanceId in _importanceIds) {
      children.add(
        GestureDetector(
          onTap: () async {
            await productPreferences.setImportance(attribute.id!, importanceId);
            final AppLocalizations? appLocalizations =
                AppLocalizations.of(context);
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) => SmoothAlertDialog(
                body: Text(
                    'blah blah blah importance "$importanceId"'), // TODO(monsieurtanuki): find translations
                actions: <SmoothActionButton>[
                  SmoothActionButton(
                    text: appLocalizations!.close,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
          child: SizedBox(
            width: importanceWidth,
            height: MINIMUM_TARGET_SIZE,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  productPreferences
                      .getPreferenceImportanceFromImportanceId(importanceId)!
                      .name!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                Icon(
                  currentImportanceId == importanceId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: themeData.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SMALL_SPACE,
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: SizedBox(
              height: MINIMUM_TARGET_SIZE,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (info != null) const Icon(Icons.info_outline),
                  Container(
                    padding: info == null
                        ? null
                        : const EdgeInsets.only(left: SMALL_SPACE),
                    child: SizedBox(
                      width: widgetWidth -
                          SMALL_SPACE -
                          (iconThemeData.size ?? DEFAULT_ICON_SIZE),
                      child: AutoSizeText(
                        attribute.settingName ?? attribute.name!,
                        maxLines: 2,
                        style: style,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: info == null
                ? null
                : () async => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        final AppLocalizations? appLocalizations =
                            AppLocalizations.of(context);
                        return SmoothAlertDialog(
                          body: Text(info),
                          actions: <SmoothActionButton>[
                            SmoothActionButton(
                              text: appLocalizations!.close,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }
}
