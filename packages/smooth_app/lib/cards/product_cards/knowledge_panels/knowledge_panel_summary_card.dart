import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';

class KnowledgePanelSummaryCard extends StatelessWidget {
  const KnowledgePanelSummaryCard(this.knowledgePanel);

  final KnowledgePanel knowledgePanel;

  @override
  Widget build(BuildContext context) {
    if (knowledgePanel.titleElement == null) {
      return EMPTY_WIDGET;
    }
    final ThemeData themeData = Theme.of(context);
    switch (knowledgePanel.titleElement!.type) {
      case TitleElementType.GRADE:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VERY_SMALL_SPACE),
              child: Text(
                knowledgePanel.topics!.first.substring(0, 1).toUpperCase() +
                    knowledgePanel.topics!.first.substring(1),
                style: themeData.textTheme.headline3,
              ),
            ),
            ScoreCard(
              iconUrl: knowledgePanel.titleElement!.iconUrl,
              description: knowledgePanel.titleElement!.title,
              cardEvaluation: getCardEvaluationFromKnowledgePanelTitleElement(
                knowledgePanel.titleElement!,
              ),
            ),
          ],
        );
      case null:
      case TitleElementType.UNKNOWN:
        return KnowledgePanelTitleCard(
          knowledgePanelTitleElement: knowledgePanel.titleElement!,
          evaluation: knowledgePanel.evaluation,
        );
    }
  }
}
