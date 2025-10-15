import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/new_knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/knowledge_panel/preview_knowledge_panels/preview_knowledge_panel.dart';

class EnvironmentKnowledgePanel extends PreviewKnowledgePanel {
  const EnvironmentKnowledgePanel({
    required super.product,
    required super.panels,
    super.key,
  });

  @override
  PreviewKnowledgePanelState<EnvironmentKnowledgePanel> createState() =>
      _EnvironmentKnowledgePanelState();
}

class _EnvironmentKnowledgePanelState
    extends PreviewKnowledgePanelState<EnvironmentKnowledgePanel> {
  @override
  Widget buildPreviewContent(BuildContext context) {
    final KnowledgePanel environmentalScorePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
          widget.product,
          'environmental_score',
        )!;

    return NewKnowledgePanelTitleCard(
      title: environmentalScorePanel.titleElement?.title ?? '',
      subtitle: environmentalScorePanel.titleElement?.subtitle ?? '',
      iconUrl: environmentalScorePanel.titleElement?.iconUrl,
    );
  }
}
