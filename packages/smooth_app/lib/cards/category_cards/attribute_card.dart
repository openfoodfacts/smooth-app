import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(
    this.attribute, {
    this.width,
    this.height,
  });

  final Attribute attribute;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SvgCache(attribute?.iconUrl, width: width, height: height);
}
