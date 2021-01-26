import 'package:flutter/material.dart';
import 'package:smooth_app/cards/data_cards/attribute_card.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class AttributeListExpandable extends StatelessWidget {
  const AttributeListExpandable({
    @required this.product,
    @required this.iconWidth,
    @required this.attributeTags,
    @required this.title,
  });

  final Product product;
  final double iconWidth;
  final List<String> attributeTags;
  final String title;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final List<Widget> chips = <Widget>[];
    final List<Widget> cards = <Widget>[];
    for (final String attributeTag in attributeTags) {
      Attribute attribute =
          UserPreferencesModel.getAttribute(product, attributeTag);
      chips.add(AttributeChip(attribute, width: iconWidth));
      if (attribute != null &&
          attribute.id == UserPreferencesModel.ATTRIBUTE_ADDITIVES) {
        // TODO(monsieurtanuki): remove that cheat when additives are more standard
        final List<String> additiveNames = product.additives?.names;
        attribute = Attribute(
          id: attribute.id,
          title: attribute.title,
          iconUrl: attribute.iconUrl,
          descriptionShort:
              additiveNames == null ? '' : additiveNames.join(', '),
        );
      }
      cards.add(AttributeCard(attribute, iconWidth));
    }
    return SmoothExpandableCard(
      headerHeight: null,
      collapsedHeader: Container(
        width: screenSize.width * 0.8,
        child: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
      ),
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards,
        ),
      ),
      expandedHeader: Text(title, style: Theme.of(context).textTheme.headline3),
    );
  }
}
