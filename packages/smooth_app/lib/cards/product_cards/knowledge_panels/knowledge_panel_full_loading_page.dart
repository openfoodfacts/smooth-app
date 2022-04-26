import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_full_page.dart';

import '../../../data_models/data_provider.dart';

class KnowledgePanelFullLoadingPage extends StatelessWidget {
  const KnowledgePanelFullLoadingPage(
      {required this.panelId, required this.barcode});

  final String panelId;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanels? knowledgePanels = context
        .select<DataProvider<Map<String, KnowledgePanels?>>, KnowledgePanels?>(
            (DataProvider<Map<String, KnowledgePanels?>> value) =>
                value.value[barcode]);

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
      Future<void>.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
      return Container();
    }
    Future<void>.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => KnowledgePanelFullPage(
            panel: knowledgePanel,
            allPanels: knowledgePanels,
          ),
        ),
      );
    });

    return Scaffold(
      body: Container(),
    );
  }
}
