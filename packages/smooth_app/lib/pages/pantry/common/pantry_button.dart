import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';

/// A button for a pantry, with the corresponding color, icon, name and shape
class PantryButton extends StatelessWidget {
  PantryButton({
    required this.pantries,
    required this.index,
    required this.onPressed,
  })  : pantryType = pantries[index].pantryType,
        onlyIcon = false;

  const PantryButton.add({
    required this.pantries,
    required this.pantryType,
    required this.onPressed,
    required this.onlyIcon,
  }) : index = null;

  final List<Pantry> pantries;
  final int index;
  final Function onPressed;
  final PantryType pantryType;
  final bool onlyIcon;

  @override
  Widget build(BuildContext context) {
    if (index == null) {
      return SmoothChip(
        onPressed: onPressed,
        iconData: Icons.add,
        label: onlyIcon
            ? null
            : _getCreateListLabel(AppLocalizations.of(context)!),
        shape: _getShape(),
      );
    }
    final Pantry pantry = pantries[index];
    return SmoothChip(
      onPressed: onPressed,
      iconData: pantry.iconData,
      label: pantry.name,
      materialColor: pantry.materialColor,
      shape: _getShape(),
    );
  }

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
