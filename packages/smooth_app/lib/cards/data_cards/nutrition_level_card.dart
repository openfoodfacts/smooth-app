import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/cards/data_cards/nutrition_level_chip.dart';

class NutritionLevelCard extends StatelessWidget {
  const NutritionLevelCard(this.attribute, this.iconWidth);

  final Attribute attribute;
  final double iconWidth;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          NutritionLevelChip(attribute, iconWidth),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  attribute.title,
                  style: Theme.of(context).textTheme.headline3,
                ),
                Text(
                  attribute.descriptionShort ?? attribute.description ?? '',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ],
      );
}
