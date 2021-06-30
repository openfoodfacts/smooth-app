import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

class AttributeChip extends StatelessWidget {
  const AttributeChip(
    this.attribute, {
    required this.height,
  });

  final Attribute attribute;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minWidth: height),
        child: SvgCache(attribute.iconUrl, height: height),
      );
}
