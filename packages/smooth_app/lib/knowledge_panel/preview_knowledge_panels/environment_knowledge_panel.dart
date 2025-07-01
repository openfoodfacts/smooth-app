import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/new_knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/knowledge_panel/preview_knowledge_panels/preview_knowledge_panel.dart';

class EnvironmentKnowledgePanel extends PreviewKnowledgePanel {
  const EnvironmentKnowledgePanel({
    super.key,
    required super.product,
    required super.panels,
  });

  @override
  PreviewKnowledgePanelState<EnvironmentKnowledgePanel> createState() =>
      _EnvironmentKnowledgePanelState();
}

class _EnvironmentKnowledgePanelState
    extends PreviewKnowledgePanelState<EnvironmentKnowledgePanel> {
  @override
  Widget buildPreviewContent(BuildContext context) {
    final KnowledgePanel nutriscorePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
      widget.product,
      'environmental_score',
    )!;

    return NewKnowledgePanelTitleCard(
      title: nutriscorePanel.titleElement?.title ?? '',
      subtitle: nutriscorePanel.titleElement?.subtitle ?? '',
      iconUrl: nutriscorePanel.titleElement?.iconUrl,
    );
  }
}
