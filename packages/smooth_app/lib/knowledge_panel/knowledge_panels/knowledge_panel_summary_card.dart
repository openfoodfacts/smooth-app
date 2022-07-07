import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_title_card.dart';

class KnowledgePanelSummaryCard extends StatelessWidget {
  const KnowledgePanelSummaryCard(
    this.knowledgePanel, {
    required this.isClickable,
    this.margin,
  });

  final KnowledgePanel knowledgePanel;
  final bool isClickable;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    if (knowledgePanel.titleElement == null) {
      return EMPTY_WIDGET;
    }
    switch (knowledgePanel.titleElement!.type) {
      case TitleElementType.GRADE:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ScoreCard(
              iconUrl: knowledgePanel.titleElement!.iconUrl,
              description: knowledgePanel.titleElement!.title,
              cardEvaluation: getCardEvaluationFromKnowledgePanelTitleElement(
                knowledgePanel.titleElement!,
              ),
              isClickable: isClickable,
              margin: margin,
            ),
          ],
        );
      case null:
      case TitleElementType.UNKNOWN:
        return KnowledgePanelTitleCard(
          knowledgePanelTitleElement: knowledgePanel.titleElement!,
          evaluation: knowledgePanel.evaluation,
          isClickable: isClickable,
        );
    }
  }
}
