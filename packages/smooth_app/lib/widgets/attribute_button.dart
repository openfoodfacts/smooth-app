import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatefulWidget {
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
  State<AttributeButton> createState() => _AttributeButtonState();
}

class _AttributeButtonState extends State<AttributeButton> {
  bool editMode = false;
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final String currentImportanceId = widget.productPreferences
        .getImportanceIdForAttributeId(widget.attribute.id!);
    const double horizontalPadding = LARGE_SPACE;
    final double widgetWidth =
        MediaQuery.sizeOf(context).width - 2 * horizontalPadding;
    final double importanceWidth = widgetWidth / 4;
    final TextStyle style = themeData.textTheme.headlineMedium!;
    final String? info = widget.attribute.settingNote;
    final List<Widget> children = <Widget>[];
    if (!editMode) {
      children.add(
        Expanded(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () async => widget.productPreferences.setImportance(
                widget.attribute.id!,
                currentImportanceId,
              ),
              child: Container(
                width: importanceWidth,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                constraints:
                    const BoxConstraints(minHeight: MINIMUM_TOUCH_SIZE),
                child: ListTile(
                  leading: Icon(
                    Icons.radio_button_checked,
                    color: themeData.colorScheme.primary,
                  ),
                  title: Text(
                    widget.productPreferences
                        .getPreferenceImportanceFromImportanceId(
                            currentImportanceId)!
                        .name!,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() => editMode = !editMode);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      for (final String importanceId in AttributeButton._importanceIds) {
        children.add(
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () async {
                  setState(() => editMode = !editMode);
                  widget.productPreferences.setImportance(
                    widget.attribute.id!,
                    importanceId,
                  );
                },
                child: Container(
                  width: importanceWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  constraints:
                      const BoxConstraints(minHeight: MINIMUM_TOUCH_SIZE),
                  child: ListTile(
                    leading: Icon(
                      currentImportanceId == importanceId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: themeData.colorScheme.primary,
                    ),
                    title: AutoSizeText(
                      widget.productPreferences
                          .getPreferenceImportanceFromImportanceId(
                              importanceId)!
                          .name!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
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
          ListTile(
            trailing: info == null ? null : const Icon(Icons.info_outline),
            title: AutoSizeText(
              widget.attribute.settingName ?? widget.attribute.name!,
              maxLines: 2,
              style: style,
            ),
            onTap: info == null
                ? null
                : () async => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        final AppLocalizations appLocalizations =
                            AppLocalizations.of(context);
                        return SmoothAlertDialog(
                          body: Text(info),
                          positiveAction: SmoothActionButton(
                            text: appLocalizations.close,
                            onPressed: () => Navigator.pop(context),
                          ),
                        );
                      },
                    ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }
}
