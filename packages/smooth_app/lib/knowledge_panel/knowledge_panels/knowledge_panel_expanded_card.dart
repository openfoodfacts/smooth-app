import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';

class KnowledgePanelExpandedCard extends StatelessWidget {
  const KnowledgePanelExpandedCard({
    required this.panelId,
    required this.product,
    required this.isInitiallyExpanded,
    required this.isClickable,
    this.roundedIcons = true,
    this.overrideStyle = true,
    this.simplified = false,
  });

  final Product product;
  final String panelId;
  final bool isInitiallyExpanded;
  final bool isClickable;
  final bool roundedIcons;
  final bool overrideStyle;
  final bool simplified;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanel panel = KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      panelId,
    )!;

    final List<Widget> elementWidgets = <Widget>[];

    final List<Widget>? summaryWidgets = _getSummary(panel);
    if (summaryWidgets != null) {
      elementWidgets.addAll(summaryWidgets);
    }

    if (panel.elements != null) {
      for (int i = 0; i < panel.elements!.length; i++) {
        final KnowledgePanelElement element = panel.elements![i];
        final Widget? elementWidget = KnowledgePanelsBuilder.getElementWidget(
          knowledgePanelElement: element,
          product: product,
          isInitiallyExpanded: isInitiallyExpanded,
          isClickable: isClickable,
          isTextSelectable: true,
          position: i,
        );
        if (elementWidget != null) {
          elementWidgets.add(
            Provider<KnowledgePanelTitleConfig>.value(
              value: KnowledgePanelTitleConfig(roundedIcon: roundedIcons),
              child: elementWidget,
            ),
          );
        }
      }
    }
    return Provider<KnowledgePanel>(
      lazy: true,
      create: (_) => panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: elementWidgets,
      ),
    );
  }

  List<Widget>? _getSummary(KnowledgePanel panel) {
    final Widget? summary = KnowledgePanelsBuilder.getPanelSummaryWidget(
      panel,
      product,
      ignoreEvaluation: true,
      textStyleOverride: overrideStyle && _hasValidEvaluation(panel.evaluation)
          ? const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: Colors.white,
            )
          : null,
      isClickable: false,
      simplified: simplified,
    );

    if (summary != null) {
      if (isInitiallyExpanded) {
        if (summary is ScoreCard) {
          return <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MEDIUM_SPACE,
              ),
              child: summary,
            ),
          ];
        }
      } else {
        return <Widget>[summary];
      }
    }

    return null;
  }

  bool _hasValidEvaluation(Evaluation? evaluation) => <Evaluation>[
    Evaluation.GOOD,
    Evaluation.AVERAGE,
    Evaluation.BAD,
  ].contains(evaluation);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('panelId', panelId));
    properties.add(
      DiagnosticsProperty<bool>('initiallyExpanded', isInitiallyExpanded),
    );
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
  }
}
