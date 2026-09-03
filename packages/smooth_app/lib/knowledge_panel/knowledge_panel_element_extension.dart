import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_action_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_image_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_text_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_world_map_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Extension on KnowledgePanelElement.
extension KnowledgePanelElementExtension on KnowledgePanelElement {
  /// Returns true if the element has something to display.
  ///
  /// cf. [getElementWidget].
  bool hasSomethingToDisplay(final Product product) {
    switch (elementType) {
      case KnowledgePanelElementType.TEXT:
      case KnowledgePanelElementType.IMAGE:
      case KnowledgePanelElementType.PANEL_GROUP:
      case KnowledgePanelElementType.TABLE:
      case KnowledgePanelElementType.MAP:
      case KnowledgePanelElementType.ACTION:
        return true;
      case KnowledgePanelElementType.UNKNOWN:
        return false;
      case KnowledgePanelElementType.PANEL:
        final String panelId = panelElement!.panelId;
        final KnowledgePanel? panel = KnowledgePanelsBuilder.getKnowledgePanel(
          product,
          panelId,
        );
        return panel != null;
    }
  }

  /// Returns the widget that displays the KP element, or rarely null.
  ///
  /// cf. [hasSomethingToDisplay].
  Widget? getElementWidget({
    required final Product product,
    required final bool isInitiallyExpanded,
    required final bool isClickable,
    required final bool isTextSelectable,
    required final int position,
    required final bool simplified,
  }) {
    switch (elementType) {
      case KnowledgePanelElementType.TEXT:
        return KnowledgePanelTextCard(textElement: textElement!);

      case KnowledgePanelElementType.IMAGE:
        return KnowledgePanelImageCard(imageElement: imageElement!);

      case KnowledgePanelElementType.PANEL:
        final String panelId = panelElement!.panelId;
        final KnowledgePanel? panel = KnowledgePanelsBuilder.getKnowledgePanel(
          product,
          panelId,
        );
        if (panel == null) {
          // happened in https://github.com/openfoodfacts/smooth-app/issues/2682
          // due to some inconsistencies in the data sent by the server
          if (panelId == 'ecoscore' &&
              (product.productType ?? ProductType.food) != ProductType.food) {
            // just ignore
          } else {
            Logs.w('unknown panel "$panelId" for barcode "${product.barcode}"');
          }
          return null;
        }
        return KnowledgePanelCard(
          panelId: panelId,
          product: product,
          isClickable: isClickable,
          simplified: simplified,
        );

      case KnowledgePanelElementType.PANEL_GROUP:
        if (simplified) {
          final List<KnowledgePanel> squarePanels = <KnowledgePanel>[];
          for (final String panelId in panelGroupElement!.panelIds) {
            final KnowledgePanel? panel =
                KnowledgePanelsBuilder.getKnowledgePanel(product, panelId);
            if (panel != null && (panel.halfWidthOnMobile ?? false)) {
              squarePanels.add(panel);
            }
          }

          if (squarePanels.isNotEmpty) {
            return KnowledgePanelSquareCard(
              panels: squarePanels,
              panelsIds: panelGroupElement?.panelIds,
              product: product,
            );
          }
        }

        return KnowledgePanelGroupCard(
          groupElement: panelGroupElement!,
          product: product,
          isClickable: isClickable,
          isTextSelectable: isTextSelectable,
          position: position,
          simplified: simplified,
        );

      case KnowledgePanelElementType.TABLE:
        return KnowledgePanelTableCard(
          tableElement: tableElement!,
          isInitiallyExpanded: isInitiallyExpanded,
          product: product,
        );

      case KnowledgePanelElementType.MAP:
        return KnowledgePanelWorldMapCard(mapElement!);

      case KnowledgePanelElementType.UNKNOWN:
        return null;

      case KnowledgePanelElementType.ACTION:
        return KnowledgePanelActionCard(actionElement!, product);
    }
  }

  List<KnowledgePanel> lookForSquarePanels(final Product product) {
    if (elementType == KnowledgePanelElementType.PANEL_GROUP) {
      final List<String>? panelIds = panelGroupElement?.panelIds;
      final List<KnowledgePanel> result = <KnowledgePanel>[];

      for (final String panelId in panelIds ?? <String>[]) {
        final KnowledgePanel? panel = KnowledgePanelsBuilder.getKnowledgePanel(
          product,
          panelId,
        );

        if (panel == null) {
          continue;
        }

        result.addAll(panel.getSquarePanels(product));
      }

      return result;
    }

    final KnowledgePanel? panel = KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      panelElement?.panelId ?? '',
    );

    if (panel == null) {
      return <KnowledgePanel>[];
    }

    return panel.getSquarePanels(product);
  }
}
