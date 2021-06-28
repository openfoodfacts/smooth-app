import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(this.attribute, this.attributeChip);

  final Attribute attribute;
  final Widget attributeChip;

  @override
  Widget build(BuildContext context) {
    final String? description =
        attribute.descriptionShort ?? attribute.description;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                attribute.title ?? '',
                style: Theme.of(context).textTheme.headline3,
              ),
              if (description != null)
                Text(
                  description,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
            ],
          ),
        ),
        attributeChip,
      ],
    );
  }
}
