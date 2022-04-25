import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';

import 'knowledge_panel_full_page.dart';

class KnowledgePanelFullLoadingPage extends StatelessWidget {
  const KnowledgePanelFullLoadingPage({required this.panelId});

  final String panelId;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanels? knowledgePanels = context.watch<KnowledgePanels?>();

    if (knowledgePanels == null) {
      return Scaffold(
        appBar: AppBar(
          title:
              Text(AppLocalizations.of(context)!.loading_dialog_default_title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final KnowledgePanel? knowledgePanel =
        knowledgePanels.panelIdToPanelMap[panelId];

    if (knowledgePanel == null) {
      Navigator.pop(context);
      return Container();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => KnowledgePanelFullPage(
          panel: knowledgePanel,
          allPanels: knowledgePanels,
        ),
      ),
    );

    return Scaffold(
      body: Container(),
    );
  }
}
