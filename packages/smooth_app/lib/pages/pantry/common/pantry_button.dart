// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A button for a pantry, with the corresponding color, icon, name and shape
class PantryButton extends StatelessWidget {
  const PantryButton(this.pantries, this.index, {this.shape});

  final List<Pantry> pantries;
  final int index;
  final OutlinedBorder shape;

  static OutlinedBorder getShapeBeveled() => const BeveledRectangleBorder(
        borderRadius: BorderRadius.horizontal(
            left: Radius.circular(16.0), right: Radius.circular(16.0)),
      );
  static OutlinedBorder getShapeRounded() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      );

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        icon: pantries[index].getIcon(
            Theme.of(context).colorScheme, ColorDestination.BUTTON_FOREGROUND),
        label: Text(
          pantries[index].name,
          style: TextStyle(
            color: SmoothTheme.getColor(
              Theme.of(context).colorScheme,
              pantries[index].materialColor,
              ColorDestination.BUTTON_FOREGROUND,
            ),
          ),
        ),
        onPressed: () async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => PantryPage(
                pantries,
                index,
                pantries[index].pantryType,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: SmoothTheme.getColor(
            Theme.of(context).colorScheme,
            pantries[index].materialColor,
            ColorDestination.BUTTON_BACKGROUND,
          ),
          shape: pantries[index].pantryType == PantryType.PANTRY
              ? null
              : getShapeBeveled(),
        ),
      );
}
