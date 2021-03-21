// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/attribute_card.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/temp/available_attribute_groups.dart';
import 'package:smooth_app/temp/product_extra.dart';

class AttributeListExpandable extends StatelessWidget {
  const AttributeListExpandable({
    @required this.product,
    @required this.iconWidth,
    @required this.attributeIds,
    this.title,
    this.collapsible = true,
    this.background,
  });

  final Product product;
  final double iconWidth;
  final List<String> attributeIds;
  final String title;
  final bool collapsible;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.of(context).size;
    final List<Widget> chips = <Widget>[];
    final List<Widget> cards = <Widget>[];
    for (final String attributeId in attributeIds) {
      Attribute attribute = ProductExtra.getAttribute(product, attributeId);
      // Some attributes selected in the user preferences might be unavailable for some products
      if (attribute == null) {
        attribute = productPreferences.getReferenceAttribute(attributeId);
        attribute = Attribute(
          id: attribute.id,
          title: attribute.name,
          iconUrl: '',
          descriptionShort: 'no data',
        );
      } else if (attribute.id == AvailableAttributeGroups.ATTRIBUTE_ADDITIVES) {
        // TODO(stephanegigandet): remove that cheat when additives are more standard
        final List<String> additiveNames = product.additives?.names;
        attribute = Attribute(
          id: attribute.id,
          title: attribute.title,
          iconUrl: attribute.iconUrl,
          descriptionShort:
              additiveNames == null ? '' : additiveNames.join(', '),
        );
      }
      chips.add(AttributeChip(attribute, width: iconWidth));
      cards.add(AttributeCard(attribute, iconWidth));
    }
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
    if (!collapsible) {
      return SmoothCard(
        content: content,
        background: background,
      );
    }

    final Widget header =
        Text(title, style: Theme.of(context).textTheme.headline3);
    return SmoothExpandableCard(
      collapsedHeader: Container(
        width: screenSize.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header,
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: chips,
            ),
          ],
        ),
      ),
      content: content,
      expandedHeader: title == null ? null : header,
    );
  }
}
