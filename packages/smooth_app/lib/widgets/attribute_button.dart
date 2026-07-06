import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/autosize_text.dart';

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatefulWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences, {
    this.isFirst = false,
    this.isLast = false,
  });

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
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    if (!editMode) {
      children.add(
        InkWell(
          onTap: () => setState(() => editMode = !editMode),
          child: ListTile(
            tileColor: context.lightTheme()
                ? Colors.white
                : theme.primaryMedium,
            shape: widget.isLast
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.vertical(
                      bottom: ROUNDED_RADIUS,
                    ),
                  )
                : null,
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 5.0, end: 2.0),
              child: Icon(
                Icons.radio_button_checked,
                color: theme.primaryBlack,
                size: 24.0,
              ),
            ),
            title: AutoSizeText(
              widget.productPreferences
                  .getPreferenceImportanceFromImportanceId(currentImportanceId)!
                  .name!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: icons.Edit(size: 18.0, color: theme.primaryBlack),
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
              tileColor: context.lightTheme()
                  ? Colors.white
                  : theme.primaryMedium,
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(start: 5.0, end: 2.0),
                child: Icon(
                  currentImportanceId == importanceId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: theme.primaryBlack,
                  size: 24.0,
                ),
              ),
              title: AutoSizeText(
                widget.productPreferences
                    .getPreferenceImportanceFromImportanceId(importanceId)!
                    .name!,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: currentImportanceId == importanceId
                      ? FontWeight.w600
                      : null,
                ),
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
                  borderRadius: BorderRadiusDirectional.vertical(
                    top: ROUNDED_RADIUS,
                  ),
                )
              : null,
          leading: getAttributeDisplayIcon(
            widget.attribute,
            context: context,
            isFoodPreferences: true,
          ),
          tileColor: context.lightTheme()
              ? theme.primaryMedium
              : theme.primaryDark,
          trailing: info == null
              ? null
              : icons.Help(
                  size: 22.0,
                  color: context.lightTheme()
                      ? theme.primaryBlack
                      : theme.primaryLight,
                ),
          title: AutoSizeText(
            widget.attribute.settingName ?? widget.attribute.name!,
            maxLines: 2,
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: context.lightTheme()
                  ? theme.primaryUltraBlack
                  : theme.primaryLight,
            ),
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
