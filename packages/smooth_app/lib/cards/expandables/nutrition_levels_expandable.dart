import 'package:flutter/material.dart';
import 'package:smooth_app/cards/data_cards/nutrition_level_card.dart';
import 'package:smooth_app/cards/data_cards/nutrition_level_chip.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class NutritionLevelsExpandable extends StatelessWidget {
  const NutritionLevelsExpandable({
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
      final Attribute attribute =
          UserPreferencesModel.getAttribute(product, attributeTag);
      chips.add(NutritionLevelChip(attribute, iconWidth));
      cards.add(NutritionLevelCard(attribute, iconWidth));
    }
    return SmoothExpandableCard(
      headerHeight: null,
      collapsedHeader: Container(
        width: screenSize.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
