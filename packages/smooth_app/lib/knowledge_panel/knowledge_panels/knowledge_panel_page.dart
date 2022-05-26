import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class KnowledgePanelPage extends StatefulWidget {
  const KnowledgePanelPage({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

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
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        themeData.colorScheme,
        SmoothTheme.getMaterialColor(context),
        ColorDestination.SURFACE_BACKGROUND,
      ),
      appBar: AppBar(
        title: widget.panel.titleElement == null
            ? null
            : Text(widget.panel.titleElement!.title),
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
}
