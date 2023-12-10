import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_enum.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_simplified_row.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_simplified_title.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_simplified_widget.dart';

/// Simplified nutriscore widget, with nutriscore and 4 other attributes.
class NutriscoreSimplifiedWidget extends StatelessWidget {
  const NutriscoreSimplifiedWidget(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          KnowledgePanelSimplifiedTitle(
            product: product,
            knowledgePanelEnum: KnowledgePanelEnum.nutriscore,
            title:
                'Qualité nutritionnelle', // TODO(monsieurtanuki): localize or let the server do it
          ),
          KnowledgePanelSimplifiedRow(
            KnowledgePanelSimplifiedWidget(
              product: product,
              knowledgePanelEnum: KnowledgePanelEnum.salt,
              title:
                  'Sel', // TODO(monsieurtanuki): localize or let the server do it
              nutrient: Nutrient.salt,
            ),
            KnowledgePanelSimplifiedWidget(
              product: product,
              knowledgePanelEnum: KnowledgePanelEnum.sugar,
              title:
                  'Sucre', // TODO(monsieurtanuki): localize or let the server do it
            ),
          ),
          KnowledgePanelSimplifiedRow(
            KnowledgePanelSimplifiedWidget(
              product: product,
              knowledgePanelEnum: KnowledgePanelEnum.fat,
              title:
                  'Matières grasses', // TODO(monsieurtanuki): localize or let the server do it
            ),
            KnowledgePanelSimplifiedWidget(
              product: product,
              knowledgePanelEnum: KnowledgePanelEnum.saturatedFat,
              title:
                  'Acides gras saturés', // TODO(monsieurtanuki): localize or let the server do it
            ),
          ),
        ],
      ),
    );
  }
}
