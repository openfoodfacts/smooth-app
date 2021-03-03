// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(this.attribute, this.iconWidth);

  final Attribute attribute;
  final double iconWidth;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AttributeChip(attribute, width: iconWidth),
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
                  _getDescription(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ],
      );

  String _getDescription() {
    return attribute.descriptionShort ?? attribute.description ?? '';
  }
}
