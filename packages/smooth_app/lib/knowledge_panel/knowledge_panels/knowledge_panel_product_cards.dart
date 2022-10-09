import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class KnowledgePanelProductCards extends StatelessWidget {
  const KnowledgePanelProductCards(this.knowledgePanelWidgets);

  final List<Widget> knowledgePanelWidgets;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetsWrappedInSmoothCards = knowledgePanelWidgets
        .map((Widget widget) => Padding(
              padding: const EdgeInsetsDirectional.only(top: VERY_LARGE_SPACE),
              child: buildProductSmoothCard(
                body: widget,
                padding: SMOOTH_CARD_PADDING,
                margin: EdgeInsets.zero,
              ),
            ))
        .toList(growable: false);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetsWrappedInSmoothCards,
        ),
      ),
    );
  }
}
