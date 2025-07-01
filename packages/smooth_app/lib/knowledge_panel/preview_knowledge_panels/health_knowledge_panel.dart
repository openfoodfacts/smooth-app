import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/new_knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/knowledge_panel/preview_knowledge_panels/preview_knowledge_panel.dart';

class HealthKnowledgePanel extends PreviewKnowledgePanel {
  const HealthKnowledgePanel({
    super.key,
    required super.product,
    required super.panels,
  });

  @override
  PreviewKnowledgePanelState<HealthKnowledgePanel> createState() =>
      _HealthKnowledgePanelState();
}

class _HealthKnowledgePanelState
    extends PreviewKnowledgePanelState<HealthKnowledgePanel> {
  @override
  Widget buildPreviewContent(BuildContext context) {
    final KnowledgePanel nutriscorePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
      widget.product,
      'nutriscore_2023',
    )!;

    final List<KnowledgePanel> squarePanels = <String>[
      'nutrient_level_fat',
      'nutrient_level_saturated-fat',
      'nutrient_level_sugars',
      'nutrient_level_salt',
    ]
        .map((String panelId) => KnowledgePanelsBuilder.getKnowledgePanel(
              widget.product,
              panelId,
            )!)
        .toList();

    final KnowledgePanel novaPanel = KnowledgePanelsBuilder.getKnowledgePanel(
      widget.product,
      'nova',
    )!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NewKnowledgePanelTitleCard(
          title: 'Qualité nutritionnelle',
          subtitle: nutriscorePanel.titleElement?.subtitle ?? '',
          iconUrl: nutriscorePanel.titleElement?.iconUrl,
        ),
        KnowledgePanelSquareCard(
          panels: squarePanels,
          product: widget.product,
        ),
        NewKnowledgePanelTitleCard(
          title: 'Transformation des aliments',
          subtitle: novaPanel.titleElement?.subtitle ?? '',
          iconUrl: novaPanel.titleElement?.iconUrl,
        ),
      ],
    );
  }
}
