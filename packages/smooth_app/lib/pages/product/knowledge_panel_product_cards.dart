import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class KnowledgePanelProductCards extends StatelessWidget {
  const KnowledgePanelProductCards(this.knowledgePanelWidgets);

  final List<Widget> knowledgePanelWidgets;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetsWrappedInSmoothCards = <Widget>[];
    for (final Widget widget in knowledgePanelWidgets) {
      widgetsWrappedInSmoothCards.add(
        Padding(
          padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
          child: buildProductSmoothCard(
            body: widget,
            padding: SMOOTH_CARD_PADDING,
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: SMALL_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetsWrappedInSmoothCards,
        ),
      ),
    );
  }
}
