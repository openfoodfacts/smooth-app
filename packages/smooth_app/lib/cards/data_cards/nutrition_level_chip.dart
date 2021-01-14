import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

class NutritionLevelChip extends StatelessWidget {
  const NutritionLevelChip(this.attribute, this.iconWidth);

  final Attribute attribute;
  final double iconWidth;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgCache(attribute.iconUrl, width: iconWidth),
      );
}
