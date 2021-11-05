import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Ingredient.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/attribute_card.dart';
import 'package:smooth_app/cards/data_cards/svg_icon_chip.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/attribute_button.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class AttributeListExpandable extends StatelessWidget {
  const AttributeListExpandable({
    required this.product,
    required this.iconHeight,
    required this.attributes,
    required this.title,
    this.collapsible = true,
    this.background,
    this.margin,
    this.padding,
    this.initiallyCollapsed = true,
  });

  final Product product;
  final double iconHeight;
  final List<Attribute> attributes;
  final String title;
  final bool collapsible;
  final Color? background;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool initiallyCollapsed;

  static List<Attribute> getPopulatedAttributes(
    final Product product,
    final List<String> attributeIds,
  ) {
    final List<Attribute> result = <Attribute>[];
    final Map<String, Attribute> attributes =
        product.getAttributes(attributeIds);
    for (final String attributeId in attributeIds) {
      Attribute? attribute = attributes[attributeId];
      // Some attributes selected in the user preferences might be unavailable for some products
      if (attribute == null) {
        continue;
      } else if (attribute.id == Attribute.ATTRIBUTE_ADDITIVES) {
        // TODO(stephanegigandet): remove that cheat when additives are more standard
        final List<String>? additiveNames = product.additives?.names;
        attribute = Attribute(
          id: attribute.id,
          title: attribute.title,
          iconUrl: attribute.iconUrl,
          descriptionShort:
              additiveNames == null ? '' : additiveNames.join(', '),
        );
      }
      result.add(attribute);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final double opacity = themeData.brightness == Brightness.light
        ? 1.0
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
    final List<Widget> chips = <Widget>[];
    final List<Widget> cards = <Widget>[];
    for (final Attribute attribute in attributes) {
      final Color color =
          getBackgroundColorFromAttribute(attribute).withOpacity(opacity);
      final Widget chip = SvgIconChip(attribute.iconUrl!, height: iconHeight);
      chips.add(
        InkWell(
          onTap: () async => AttributeButton.onTap(
            context: context,
            attributeId: attribute.id!, //Can cause errors
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
            attributeId: attribute.id!, //Can cause errors
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
              child: AttributeCard(
                attribute,
                chip,
                barcode: product.barcode,
              ),
            ),
          ),
        ),
      );
    }
    // TODO(justinmc): Make this prettier.
    // TODO(justinmc): Make this less hacky and hard coded. Button parameter?
    if (title == 'Ingredients') {
      cards.add(TextButton(
        onPressed: () async => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) =>
                EditIngredientsPage(
                  ingredients: product.ingredients ?? <Ingredient>[],
                ),
          ),
        ),
        child: const Text('Edit ingredients'),
      ));
    }
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
    if (!collapsible) {
      return SmoothCard(
        margin: margin,
        padding: padding,
        child: content,
        color: background,
      );
    }

    final Widget header =
        Text(title, style: Theme.of(context).textTheme.headline3);
    return SmoothExpandableCard(
      margin: margin,
      padding: padding,
      initiallyCollapsed: initiallyCollapsed,
      collapsedHeader: SizedBox(
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
      expandedHeader: header,
    );
  }
}
