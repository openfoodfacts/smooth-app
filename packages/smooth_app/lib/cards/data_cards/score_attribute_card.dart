import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ScoreAttributeCard extends StatelessWidget {
  const ScoreAttributeCard({
    required this.attribute,
    required this.iconHeight,
  });

  final Attribute attribute;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
    final Color backgroundColor =
        getBackgroundColor(attribute).withOpacity(opacity);
    final Color textColor = getTextColor(attribute).withOpacity(opacity);
    final AttributeChip attributeChip =
        AttributeChip(attribute, height: iconHeight);
    final String? description =
        attribute.descriptionShort ?? attribute.description;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            attributeChip,
            if (description != null)
              Expanded(
                  child: Center(
                      child: Text(
                description,
                style: themeData.textTheme.headline4!.apply(color: textColor),
              ))),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
