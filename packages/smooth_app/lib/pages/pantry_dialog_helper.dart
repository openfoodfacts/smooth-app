// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

// Project imports:
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A dialog helper for pantries
class PantryDialogHelper {
  static const String _TRANSLATE_ME_WANT_TO_DELETE_PANTRY =
      'Do you want to delete this pantry?';
  static const String _TRANSLATE_ME_WANT_TO_DELETE_SHOPPING =
      'Do you want to delete this shopping list?';
  static const String _TRANSLATE_ME_NEW_LIST_PANTRY = 'New pantry';
  static const String _TRANSLATE_ME_NEW_LIST_SHOPPING = 'New shopping list';
  static const String _TRANSLATE_ME_RENAME_LIST_PANTRY = 'Rename pantry';
  static const String _TRANSLATE_ME_RENAME_LIST_SHOPPING =
      'Rename shopping list';
  static const String _TRANSLATE_ME_CHANGE_ICON = 'Change icon';
  static const String _TRANSLATE_ME_HINT_PANTRY = 'My own pantry';
  static const String _TRANSLATE_ME_HINT_SHOPPING = 'My shopping list';
  static const String _TRANSLATE_ME_EMPTY = 'Please enter some text';
  static const String _TRANSLATE_ME_ALREADY_OTHER_PANTRY =
      'There\'s already a pantry with that name';
  static const String _TRANSLATE_ME_ALREADY_OTHER_SHOPPING =
      'There\'s already a shopping list with that name';
  static const String _TRANSLATE_ME_ALREADY_SAME = 'That\'s the same name!';
  static const String _TRANSLATE_ME_CANCEL = 'Cancel';

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
                ? _TRANSLATE_ME_WANT_TO_DELETE_PANTRY
                : _TRANSLATE_ME_WANT_TO_DELETE_SHOPPING,
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

  static Future<bool> openNew(
    final BuildContext context,
    final List<Pantry> pantries,
    final PantryType pantryType,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: pantryType == PantryType.PANTRY
            ? _TRANSLATE_ME_NEW_LIST_PANTRY
            : _TRANSLATE_ME_NEW_LIST_SHOPPING,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: pantryType == PantryType.PANTRY
                      ? _TRANSLATE_ME_HINT_PANTRY
                      : _TRANSLATE_ME_HINT_SHOPPING,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return _TRANSLATE_ME_EMPTY;
                  }
                  if (pantries == null) {
                    return null;
                  }
                  for (int i = 0; i < pantries.length; i++) {
                    if (value == pantries[i].name) {
                      return pantryType == PantryType.PANTRY
                          ? _TRANSLATE_ME_ALREADY_OTHER_PANTRY
                          : _TRANSLATE_ME_ALREADY_OTHER_SHOPPING;
                    }
                  }
                  pantries.add(Pantry(name: value, pantryType: pantryType));
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: _TRANSLATE_ME_CANCEL,
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
            ? _TRANSLATE_ME_RENAME_LIST_PANTRY
            : _TRANSLATE_ME_RENAME_LIST_SHOPPING,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: pantries[index].name,
                decoration: InputDecoration(
                  hintText: pantries[index].pantryType == PantryType.PANTRY
                      ? _TRANSLATE_ME_HINT_PANTRY
                      : _TRANSLATE_ME_HINT_SHOPPING,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return _TRANSLATE_ME_EMPTY;
                  }
                  if (pantries == null) {
                    return null;
                  }
                  for (int i = 0; i < pantries.length; i++) {
                    if (value == pantries[i].name) {
                      if (i == index) {
                        return _TRANSLATE_ME_ALREADY_SAME;
                      }
                      return pantries[index].pantryType == PantryType.PANTRY
                          ? _TRANSLATE_ME_ALREADY_OTHER_PANTRY
                          : _TRANSLATE_ME_ALREADY_OTHER_SHOPPING;
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
            text: _TRANSLATE_ME_CANCEL,
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
        title: _TRANSLATE_ME_CHANGE_ICON,
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
            text: _TRANSLATE_ME_CANCEL,
            onPressed: () => Navigator.pop(context, false),
            important: false,
          ),
        ],
      ),
    );
  }
}
