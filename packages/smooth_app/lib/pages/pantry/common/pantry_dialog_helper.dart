// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

// Project imports:
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A dialog helper for pantries
class PantryDialogHelper {
  static Future<bool> openDelete(
    final BuildContext context,
    final List<Pantry> pantries,
    final int index,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          close: false,
          body: Text(
            pantries[index].pantryType == PantryType.PANTRY
                ? AppLocalizations.of(context).want_to_delete_pantry
                : AppLocalizations.of(context).want_to_delete_shopping,
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context).no,
              important: false,
              onPressed: () => Navigator.pop(context, false),
            ),
            SmoothSimpleButton(
              text: AppLocalizations.of(context).yes,
              important: true,
              onPressed: () async {
                pantries.removeAt(index);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );

  static Future<String> openNew(
    final BuildContext context,
    final List<Pantry> pantries,
    final PantryType pantryType,
    final UserPreferences userPreferences,
  ) async {
    String newPantryName;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: pantryType == PantryType.PANTRY
            ? AppLocalizations.of(context).new_pantry
            : AppLocalizations.of(context).new_shopping,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: pantryType == PantryType.PANTRY
                      ? AppLocalizations.of(context).my_pantry_hint
                      : AppLocalizations.of(context).my_shopping_hint,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context).empty_list;
                  }
                  if (pantries == null) {
                    return null;
                  }
                  for (int i = 0; i < pantries.length; i++) {
                    if (value == pantries[i].name) {
                      return pantryType == PantryType.PANTRY
                          ? AppLocalizations.of(context).pantry_name_taken
                          : AppLocalizations.of(context).shopping_name_taken;
                    }
                  }
                  pantries.add(Pantry(
                    name: value,
                    pantryType: pantryType,
                    order: <String>[],
                  ));
                  Pantry.putAll(
                    userPreferences,
                    pantries,
                    pantryType,
                  );
                  newPantryName = value;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context, null),
            important: false,
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).okay,
            onPressed: () async {
              if (!formKey.currentState.validate()) {
                return;
              }
              Navigator.pop(context, newPantryName);

              int index = 0;
              for (final Pantry pantry in pantries) {
                if (pantry.name == newPantryName) {
                  await Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) => PantryPage(
                        pantries,
                        index,
                        pantryType,
                      ),
                    ),
                  );
                  return;
                }
                index++;
              }
            },
            important: true,
          ),
        ],
      ),
    );
  }

  static Future<bool> openRename(
    final BuildContext context,
    final List<Pantry> pantries,
    final int index,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: pantries[index].pantryType == PantryType.PANTRY
            ? AppLocalizations.of(context).rename_pantry
            : AppLocalizations.of(context).rename_shopping,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: pantries[index].name,
                decoration: InputDecoration(
                  hintText: pantries[index].pantryType == PantryType.PANTRY
                      ? AppLocalizations.of(context).my_pantry_hint
                      : AppLocalizations.of(context).my_shopping_hint,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context).empty_list;
                  }
                  if (pantries == null) {
                    return null;
                  }
                  for (int i = 0; i < pantries.length; i++) {
                    if (value == pantries[i].name) {
                      if (i == index) {
                        return AppLocalizations.of(context).already_same;
                      }
                      return pantries[index].pantryType == PantryType.PANTRY
                          ? AppLocalizations.of(context).pantry_name_taken
                          : AppLocalizations.of(context).shopping_name_taken;
                    }
                  }
                  pantries[index].name = value;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context, false),
            important: false,
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).okay,
            onPressed: () async {
              if (!formKey.currentState.validate()) {
                return;
              }
              Navigator.pop(context, true);
            },
            important: true,
          ),
        ],
      ),
    );
  }

  static Future<bool> openChangeIcon(
    final BuildContext context,
    final List<Pantry> pantries,
    final int index,
  ) async {
    final Pantry pantry = pantries[index];
    final List<String> orderedIcons = pantries[index].getPossibleIcons();
    const List<String> orderedColors = Pantry.ORDERED_COLORS;
    final double size = MediaQuery.of(context).size.width / 8;
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: AppLocalizations.of(context).change_icon,
        body: Container(
          width: orderedColors.length.toDouble() * size,
          height: orderedIcons.length.toDouble() * size,
          child: GridView.count(
            crossAxisCount: 5,
            childAspectRatio: 1,
            children: List<Widget>.generate(
              orderedColors.length * orderedIcons.length,
              (final int index) {
                final String colorTag =
                    orderedColors[index % orderedColors.length];
                final String iconTag =
                    orderedIcons[index ~/ orderedColors.length];
                return IconButton(
                  icon: pantry.getReferenceIcon(
                    colorScheme: Theme.of(context).colorScheme,
                    colorTag: colorTag,
                    iconTag: iconTag,
                    colorDestination: ColorDestination.SURFACE_FOREGROUND,
                  ),
                  onPressed: () async {
                    pantry.colorTag = colorTag;
                    pantry.iconTag = iconTag;
                    Navigator.pop(context, true);
                  },
                );
              },
            ),
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.pop(context, false),
            important: false,
          ),
        ],
      ),
    );
  }
}
