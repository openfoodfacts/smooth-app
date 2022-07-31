import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_action_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_world_map_card.dart';
import 'package:smooth_app/services/smooth_services.dart';

class KnowledgePanelElementCard extends StatelessWidget {
  const KnowledgePanelElementCard({
    required this.knowledgePanelElement,
    required this.allPanels,
    required this.product,
    required this.isInitiallyExpanded,
  });

  final KnowledgePanelElement knowledgePanelElement;
  final KnowledgePanels allPanels;
  final Product product;
  final bool isInitiallyExpanded;

  @override
  Widget build(BuildContext context) {
    switch (knowledgePanelElement.elementType) {
      case KnowledgePanelElementType.TEXT:
        return _KnowledgePanelTextElementCard(
          textElement: knowledgePanelElement.textElement!,
        );
      case KnowledgePanelElementType.IMAGE:
        return Image.network(
          knowledgePanelElement.imageElement!.url,
          width: knowledgePanelElement.imageElement!.width?.toDouble(),
          height: knowledgePanelElement.imageElement!.height?.toDouble(),
        );
      case KnowledgePanelElementType.PANEL:
        final String panelId = knowledgePanelElement.panelElement!.panelId;
        final KnowledgePanel? panel = allPanels.panelIdToPanelMap[panelId];
        if (panel == null) {
          // happened in https://github.com/openfoodfacts/smooth-app/issues/2682
          // due to some inconsistencies in the data sent by the server
          Logs.w(
            'unknown panel "$panelId" for barcode "${product.barcode}"',
          );
          return EMPTY_WIDGET;
        }
        return KnowledgePanelCard(
          panel: panel,
          allPanels: allPanels,
          product: product,
        );
      case KnowledgePanelElementType.PANEL_GROUP:
        return KnowledgePanelGroupCard(
          groupElement: knowledgePanelElement.panelGroupElement!,
          allPanels: allPanels,
          product: product,
        );
      case KnowledgePanelElementType.TABLE:
        return KnowledgePanelTableCard(
          tableElement: knowledgePanelElement.tableElement!,
          isInitiallyExpanded: isInitiallyExpanded,
        );
      case KnowledgePanelElementType.MAP:
        return KnowledgePanelWorldMapCard(knowledgePanelElement.mapElement!);
      case KnowledgePanelElementType.UNKNOWN:
        return EMPTY_WIDGET;
      case KnowledgePanelElementType.ACTION:
        return KnowledgePanelActionCard(
          knowledgePanelElement.actionElement!,
          product,
        );
      default:
        Logs.e('unexpected element type: ${knowledgePanelElement.elementType}');
        return EMPTY_WIDGET;
    }
  }
}

/// A Knowledge Panel Text element may contain a source.
/// This widget add this information if needed and allows to open the url
/// (if provided)
class _KnowledgePanelTextElementCard extends StatelessWidget {
  const _KnowledgePanelTextElementCard({
    required this.textElement,
    Key? key,
  }) : super(key: key);

  final KnowledgePanelTextElement textElement;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    Widget text = SmoothHtmlWidget(
      textElement.html,
    );

    if (hasSource) {
      text = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text,
          const SizedBox(
            height: MEDIUM_SPACE,
          ),
          // Remove Icon
          IconTheme.merge(
            data: const IconThemeData(
              size: 0.0,
            ),
            child: addPanelButton(
              appLocalizations
                  .knowledge_panel_text_source(textElement.sourceText!),
              iconData: null,
              onPressed: () {
                LaunchUrlHelper.launchURL(
                  textElement.sourceUrl!,
                  false,
                );
              },
            ),
          ),
        ],
      );
    }

    return text;
  }

  bool get hasSource =>
      textElement.sourceText?.isNotEmpty == true &&
      textElement.sourceUrl?.isNotEmpty == true;
}
