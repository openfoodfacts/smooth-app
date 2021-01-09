import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/attribute_card.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class AttributeExpandable extends StatelessWidget {
  const AttributeExpandable(this.attribute);

  final Attribute attribute;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    return SmoothExpandableCard(
      headerHeight: 50.0,
      collapsedHeader: Row(children: <Widget>[
        AttributeCard(attribute, width: screenSize.width * 0.25),
        const SizedBox(
          width: 12.0,
        ),
        Container(
          width: screenSize.width * 0.5,
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(attribute.description),
              )
            ],
          ),
        ),
      ]),
      content: AttributeCard(attribute, width: 150),
      expandedHeader:
          Text(attribute.name, style: themeData.textTheme.headline3),
    );
  }
}
