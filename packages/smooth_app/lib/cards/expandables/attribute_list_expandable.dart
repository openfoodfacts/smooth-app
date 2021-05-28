import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:smooth_app/cards/data_cards/attribute_card.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/pages/attribute_button.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class AttributeListExpandable extends StatelessWidget {
  const AttributeListExpandable({
    @required this.product,
    @required this.iconHeight,
    @required this.attributeIds,
    this.title,
    this.collapsible = true,
    this.background,
    this.padding,
    this.insets,
    this.initiallyCollapsed = true,
  });

  final Product product;
  final double iconHeight;
  final List<String> attributeIds;
  final String title;
  final bool collapsible;
  final Color background;
  final EdgeInsets padding;
  final EdgeInsets insets;
  final bool initiallyCollapsed;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
    final List<Widget> chips = <Widget>[];
    final List<Widget> cards = <Widget>[];
    final Map<String, Attribute> attributes = product.getAttributes(
      attributeIds,
    );
    for (final String attributeId in attributeIds) {
      Attribute attribute = attributes[attributeId];
      // Some attributes selected in the user preferences might be unavailable for some products
      if (attribute == null) {
        attribute = productPreferences.getReferenceAttribute(attributeId);
        attribute = Attribute(
          id: attribute.id,
          title: attribute.name,
          iconUrl: '',
          descriptionShort: 'no data',
        );
      } else if (attribute.id == Attribute.ATTRIBUTE_ADDITIVES) {
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
      final Color color = _getBackgroundColor(attribute).withOpacity(opacity);
      final Widget chip = AttributeChip(attribute, height: iconHeight);
      chips.add(
        InkWell(
          onTap: () async => AttributeButton.onTap(
            context: context,
            attributeId: attribute.id,
            productPreferences: productPreferences,
            themeProvider: themeProvider,
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: chip,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      );
      cards.add(
        InkWell(
          onTap: () async => AttributeButton.onTap(
            context: context,
            attributeId: attribute.id,
            productPreferences: productPreferences,
            themeProvider: themeProvider,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: AttributeCard(attribute, chip),
            ),
          ),
        ),
      );
    }
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
    if (!collapsible) {
      return SmoothCard(
        padding: padding,
        insets: insets,
        child: content,
        color: background,
      );
    }

    final Widget header =
        Text(title, style: Theme.of(context).textTheme.headline3);
    return SmoothExpandableCard(
      padding: padding,
      insets: insets,
      initiallyCollapsed: initiallyCollapsed,
      collapsedHeader: Container(
        width: screenSize.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header,
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: chips,
                runSpacing: 8.0,
                spacing: 8.0,
              ),
            ),
          ],
        ),
      ),
      child: content,
      expandedHeader: title == null ? null : header,
    );
  }

  static Color _getBackgroundColor(final Attribute attribute) {
    if (attribute.status == Attribute.STATUS_KNOWN) {
      if (attribute.match <= 20) {
        return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
      }
      if (attribute.match <= 40) {
        return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
      }
      if (attribute.match <= 60) {
        return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
      }
      if (attribute.match <= 80) {
        return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
      }
      return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
    } else {
      return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
    }
  }
}
