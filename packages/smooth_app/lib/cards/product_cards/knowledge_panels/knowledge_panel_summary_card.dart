import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';

import 'package:smooth_ui_library/util/ui_helpers.dart';

class KnowledgePanelSummaryCard extends StatelessWidget {
  const KnowledgePanelSummaryCard(this.knowledgePanel);

  final KnowledgePanel knowledgePanel;

  @override
  Widget build(BuildContext context) {
    if (knowledgePanel.titleElement == null) {
      return EMPTY_WIDGET;
    }
    if (knowledgePanel.titleElement!.type == TitleElementType.GRADE) {
      return ScoreCard(
        iconUrl: knowledgePanel.titleElement!.iconUrl!,
        description: knowledgePanel.titleElement!.title,
        cardEvaluation: getCardEvaluationFromKnowledgePanelTitleElement(
            knowledgePanel.titleElement!,
        ),
      );
    }
    return KnowledgePanelTitleCard(
      knowledgePanelTitleElement: knowledgePanel.titleElement!,
      evaluation: knowledgePanel.evaluation,
    );
  }
}
