import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';

class KnowledgePanelSummaryCard extends StatelessWidget {
  const KnowledgePanelSummaryCard(this.knowledgePanel);

  final KnowledgePanel knowledgePanel;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    if (knowledgePanel.type == KnowledgePanelType.SCORE) {
      return ScoreCard(
        iconUrl: knowledgePanel.titleElement.iconUrl!,
        description: knowledgePanel.titleElement.title,
        cardEvaluation: getCardEvaluationFromKnowledgePanel(knowledgePanel),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (knowledgePanel.name != null)
            Text(
              knowledgePanel.name!,
              style: themeData.textTheme.subtitle2!.apply(color: Colors.grey),
            ),
          KnowledgePanelTitleCard(
            knowledgePanelTitleElement: knowledgePanel.titleElement,
            evaluation: knowledgePanel.evaluation,
          )
        ],
      ),
    );
  }
}
