import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';

class KnowledgePanelProductCards extends StatelessWidget {
  const KnowledgePanelProductCards(
    this.knowledgePanelWidgets, {
    this.template = false,
  });

  final List<Widget> knowledgePanelWidgets;

  /// Whether this is a template panel
  final bool template;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetsWrappedInSmoothCards = knowledgePanelWidgets
        .map((Widget widget) {
          /// When we have a panel with a title (e.g. "Health"), we change
          /// a bit the layout
          final bool hasTitle =
              widget is Column && widget.children.first is KnowledgePanelTitle;
          final Widget content;

          if (hasTitle) {
            content = buildProductSmoothCard(
              title: Text((widget.children.first as KnowledgePanelTitle).title),
              body: Material(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SMALL_SPACE,
                    vertical: SMALL_SPACE,
                  ),
                  child: Column(children: widget.children.sublist(1)),
                ),
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            );
          } else {
            content = buildProductSmoothCard(
              body: widget,
              padding: SMOOTH_CARD_PADDING,
              margin: EdgeInsets.zero,
            );
          }

          return Padding(
            padding: const EdgeInsetsDirectional.only(top: VERY_LARGE_SPACE),
            child: content,
          );
        })
        .toList(growable: false);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetsWrappedInSmoothCards,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', knowledgePanelWidgets.length));
  }
}
