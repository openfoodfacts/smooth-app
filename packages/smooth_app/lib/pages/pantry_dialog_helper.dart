import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

/// A dialog helper for pantries
class PantryDialogHelper {
  static const String _TRANSLATE_ME_WANT_TO_DELETE =
      'Do you want to delete this pantry?';
  static const String _TRANSLATE_ME_NEW_LIST = 'New pantry';
  static const String _TRANSLATE_ME_RENAME_LIST = 'Rename pantry';
  static const String _TRANSLATE_ME_CHANGE_ICON = 'Change icon';
  static const String _TRANSLATE_ME_HINT = 'My own pantry';
  static const String _TRANSLATE_ME_EMPTY = 'Please enter some text';
  static const String _TRANSLATE_ME_ALREADY_OTHER =
      'There\'s already a pantry with that name';
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
          body: const Text(_TRANSLATE_ME_WANT_TO_DELETE),
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
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: _TRANSLATE_ME_NEW_LIST,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: _TRANSLATE_ME_HINT,
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
                      return _TRANSLATE_ME_ALREADY_OTHER;
                    }
                  }
                  pantries.add(Pantry(name: value));
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
        title: _TRANSLATE_ME_RENAME_LIST,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: pantries[index].name,
                decoration: const InputDecoration(
                  hintText: _TRANSLATE_ME_HINT,
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
                      return _TRANSLATE_ME_ALREADY_OTHER;
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
    final List<String> orderedColors = Pantry.ORDERED_COLORS;
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
                  icon: Pantry.getReferenceIcon(
                    colorScheme: Theme.of(context).colorScheme,
                    colorTag: colorTag,
                    iconTag: iconTag,
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
