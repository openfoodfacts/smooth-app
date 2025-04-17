import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatefulWidget {
  const AttributeButton(this.attribute, this.productPreferences,
      {this.isFirst = false, this.isLast = false});

  final bool isFirst;
  final bool isLast;
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
    final TextStyle style = themeData.textTheme.headlineMedium!;
    final String? info = widget.attribute.settingNote;
    final List<Widget> children = <Widget>[];
    if (!editMode) {
      children.add(
        InkWell(
          onTap: () async => widget.productPreferences.setImportance(
            widget.attribute.id!,
            currentImportanceId,
          ),
          child: ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            shape: widget.isLast
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: ROUNDED_RADIUS,
                      bottomRight: ROUNDED_RADIUS,
                    ),
                  )
                : null,
            leading: Icon(
              Icons.radio_button_checked,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            title: AutoSizeText(
              widget.productPreferences
                  .getPreferenceImportanceFromImportanceId(currentImportanceId)!
                  .name!,
            ),
            trailing: GestureDetector(
                child: const Icon(Icons.edit, size: DEFAULT_ICON_SIZE),
                onTap: () => setState(() => editMode = !editMode)),
          ),
        ),
      );
    } else {
      for (final String importanceId in AttributeButton._importanceIds) {
        children.add(
          InkWell(
            onTap: () async {
              setState(() => editMode = !editMode);
              widget.productPreferences.setImportance(
                widget.attribute.id!,
                importanceId,
              );
            },
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              leading: Icon(
                currentImportanceId == importanceId
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              title: AutoSizeText(
                widget.productPreferences
                    .getPreferenceImportanceFromImportanceId(importanceId)!
                    .name!,
                maxLines: 2,
              ),
            ),
          ),
        );
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          shape: widget.isFirst
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: ROUNDED_RADIUS,
                    topRight: ROUNDED_RADIUS,
                  ),
                )
              : null,
          leading: getAttributeDisplayIcon(
            widget.attribute,
            context: context,
            isFoodPreferences: true,
          ),
          tileColor: Theme.of(context).colorScheme.secondary,
          trailing: info == null
              ? null
              : const Icon(Icons.help_outline, size: DEFAULT_ICON_SIZE),
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
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ],
    );
  }
}
