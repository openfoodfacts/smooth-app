import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/data_models/data_provider.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';

// Just to be called from the product page with the right provider set up
class ProductPageKnowledgePanels extends StatelessWidget {
  const ProductPageKnowledgePanels({
    required this.product,
    required this.setState,
  });

  final Function(Function()) setState;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanels? knowledgePanels = context
        .select<DataProvider<Map<String, KnowledgePanels?>>, KnowledgePanels?>(
            (DataProvider<Map<String, KnowledgePanels?>> value) =>
                value.value[product.barcode]);

    List<Widget> knowledgePanelWidgets = <Widget>[];

    if (knowledgePanels != null) {
      // Render all KnowledgePanels
      knowledgePanelWidgets =
          KnowledgePanelsBuilder(setState: () => setState(() {})).buildAll(
        knowledgePanels,
        context: context,
        product: product,
      );
    } else {
      // Query results not available yet.
      knowledgePanelWidgets = <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            ],
          ),
        ),
      ];
    }
    return KnowledgePanelProductCards(knowledgePanelWidgets);
  }
}
