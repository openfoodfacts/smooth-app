import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';
import 'package:smooth_app/pages/product/add_category_button.dart';
import 'package:smooth_app/pages/product/add_ingredients_button.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// "Contribute Actions" for the knowledge panels.
class KnowledgePanelActionCard extends StatelessWidget {
  const KnowledgePanelActionCard(this.element, this.product);

  final KnowledgePanelActionElement element;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actionWidgets = <Widget>[];
    for (final String action in element.actions) {
      switch (action) {
        case KnowledgePanelActionElement.ACTION_ADD_CATEGORIES:
          actionWidgets.add(AddCategoryButton(product));
          break;
        case KnowledgePanelActionElement.ACTION_ADD_INGREDIENTS_TEXT:
          actionWidgets.add(AddIngredientsButton(product));
          break;
        case KnowledgePanelActionElement.ACTION_ADD_NUTRITION_FACTS:
          actionWidgets.add(AddNutritionButton(product));
          break;
        default:
          Logs.e('unknown knowledge panel action: $action');
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SmoothHtmlWidget(element.html),
        const SizedBox(height: SMALL_SPACE),
        ...actionWidgets,
      ],
    );
  }
}
