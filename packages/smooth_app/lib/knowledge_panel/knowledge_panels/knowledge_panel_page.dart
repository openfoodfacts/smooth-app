import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';

class KnowledgePanelPage extends StatefulWidget {
  const KnowledgePanelPage({
    required this.panel,
    required this.allPanels,
    this.groupElement,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;
  final KnowledgePanelPanelGroupElement? groupElement;

  @override
  State<KnowledgePanelPage> createState() => _KnowledgePanelPageState();
}

class _KnowledgePanelPageState extends State<KnowledgePanelPage>
    with TraceableClientMixin {
  @override
  String get traceName =>
      'Opened full knowledge panel page ${widget.panel.titleElement?.title}';

  @override
  String get traceTitle => 'knowledge_panel_page';

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.trackKnowledgePanelOpen();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: SingleChildScrollView(
        child: SmoothCard(
          padding: const EdgeInsets.all(
            SMALL_SPACE,
          ),
          child: KnowledgePanelExpandedCard(
            panel: widget.panel,
            allPanels: widget.allPanels,
          ),
        ),
      ),
    );
  }

  String get _title {
    if (widget.groupElement?.title.isNotEmpty == true) {
      return widget.groupElement!.title;
    } else if (widget.panel.titleElement?.title.isNotEmpty == true) {
      return widget.panel.titleElement!.title;
    } else {
      return '';
    }
  }
}
