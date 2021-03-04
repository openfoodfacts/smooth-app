// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';

// Project imports:
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

class AttributeChip extends StatelessWidget {
  const AttributeChip(
    this.attribute, {
    this.width,
    this.height,
  });

  final Attribute attribute;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgCache(attribute?.iconUrl, width: width, height: height),
      );
}
