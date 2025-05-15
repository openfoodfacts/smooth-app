import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    if (!editMode) {
      children.add(
        InkWell(
          onTap: () async => widget.productPreferences.setImportance(
            widget.attribute.id!,
            currentImportanceId,
          ),
          child: ListTile(
            tileColor:
                context.lightTheme() ? Colors.white : extension.primaryMedium,
            shape: widget.isLast
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.vertical(
                      bottom: ROUNDED_RADIUS,
                    ),
                  )
                : null,
            leading: Icon(
              Icons.radio_button_checked,
              color: extension.primaryBlack,
              size: 32.0,
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
            trailing: GestureDetector(
                child: Icon(
                  Icons.edit,
                  size: DEFAULT_ICON_SIZE,
                  color: extension.primaryBlack,
                ),
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
                color: extension.primaryBlack,
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
              ? extension.primaryMedium
              : extension.primaryDark,
          trailing: info == null
              ? null
              : Icon(
                  Icons.help_outline,
                  size: DEFAULT_ICON_SIZE,
                  color: context.lightTheme()
                      ? extension.primaryBlack
                      : extension.primaryLight,
                ),
          title: AutoSizeText(
            widget.attribute.settingName ?? widget.attribute.name!,
            maxLines: 2,
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: context.lightTheme()
                  ? extension.primaryUltraBlack
                  : extension.primaryLight,
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
