import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A button for a pantry, with the corresponding color, icon, name and shape
class PantryButton extends StatelessWidget {
  PantryButton({
    @required this.pantries,
    @required this.index,
    @required this.onPressed,
  }) : pantryType = pantries[index].pantryType;

  const PantryButton.add({
    @required this.pantries,
    @required this.pantryType,
    @required this.onPressed,
  }) : index = null;

  final List<Pantry> pantries;
  final int index;
  final Function onPressed;
  final PantryType pantryType;

  @override
  Widget build(BuildContext context) {
    if (index == null) {
      return _build(
        const Icon(Icons.add),
        Flexible(
          child: Text(
            _getCreateListLabel(AppLocalizations.of(context)),
            overflow: TextOverflow.fade,
          ),
        ),
        null,
      );
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Pantry pantry = pantries[index];
    final MaterialColor materialColor = pantry.materialColor;
    return _build(
      pantry.getIcon(colorScheme, ColorDestination.BUTTON_FOREGROUND),
      Text(
        pantry.name,
        style: TextStyle(
          color: SmoothTheme.getColor(
            colorScheme,
            materialColor,
            ColorDestination.BUTTON_FOREGROUND,
          ),
        ),
      ),
      SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.BUTTON_BACKGROUND,
      ),
    );
  }

  Widget _build(
    final Widget icon,
    final Widget label,
    final Color primary,
  ) =>
      ElevatedButton.icon(
        icon: icon,
        label: label,
        onPressed: () async => await onPressed(),
        style: ElevatedButton.styleFrom(
          primary: primary,
          shape: _getShape(),
        ),
      );

  String _getCreateListLabel(final AppLocalizations appLocalizations) {
    switch (pantryType) {
      case PantryType.PANTRY:
        return appLocalizations.new_pantry;
      case PantryType.SHOPPING:
        return appLocalizations.new_shopping;
    }
    throw Exception('unknow pantry type $pantryType');
  }

  OutlinedBorder _getShape() {
    switch (pantryType) {
      case PantryType.PANTRY:
        return null;
      case PantryType.SHOPPING:
        return const BeveledRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(16.0),
            right: Radius.circular(16.0),
          ),
        );
    }
    throw Exception('unknow pantry type $pantryType');
  }
}
