import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry_page.dart';
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
        icon: pantries[index].getIcon(Theme.of(context).colorScheme),
        label: Text(pantries[index].name),
        onPressed: () async {
          await Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => PantryPage(pantries, index),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: SmoothTheme.getBackgroundColor(
            Theme.of(context).colorScheme,
            pantries[index].materialColor,
          ),
          shape: shape,
        ),
      );
}
