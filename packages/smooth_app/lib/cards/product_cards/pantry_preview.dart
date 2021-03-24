// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/product_list_preview_helper.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// A preview button for a pantry, with its N first products
class PantryPreview extends StatelessWidget {
  const PantryPreview({
    @required this.pantries,
    @required this.index,
    @required this.nbInPreview,
  });

  final List<Pantry> pantries;
  final int index;
  final int nbInPreview;

  @override
  Widget build(BuildContext context) {
    final Pantry pantry = pantries[index];
    final List<Product> list = pantry.getFirstProducts(nbInPreview);

    String subtitle;
    final double iconSize = MediaQuery.of(context).size.width / 6;
    if (list == null || list.isEmpty) {
      subtitle = 'Empty list';
    }
    return Card(
      color: SmoothTheme.getColor(
        Theme.of(context).colorScheme,
        pantry.materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () async => await Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => PantryPage(
                  pantries,
                  index,
                  pantries[index].pantryType,
                ),
              ),
            ),
            leading: pantry.getIcon(
              Theme.of(context).colorScheme,
              ColorDestination.SURFACE_FOREGROUND,
            ),
            trailing: const Icon(Icons.arrow_forward),
            subtitle: subtitle == null ? null : Text(subtitle),
            title:
                Text(pantry.name, style: Theme.of(context).textTheme.subtitle2),
          ),
          ProductListPreviewHelper(list: list, iconSize: iconSize),
        ],
      ),
    );
  }
}
