import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_element_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/new_knowledge_panel_title_card.dart';

/// Extension on KnowledgePanel.
extension KnowledgePanelExtension on KnowledgePanel {
  bool hasSomethingToDisplay(final Product product) {
    if (elements == null) {
      return false;
    }
    for (final KnowledgePanelElement element in elements!) {
      if (element.hasSomethingToDisplay(product)) {
        return true;
      }
    }
    return false;
  }

  List<KnowledgePanel> getSquarePanels(final Product product) {
    if ((halfWidthOnMobile ?? false) || (evaluation != null)) {
      return <KnowledgePanel>[this];
    }

    return elements
            ?.map((KnowledgePanelElement e) => e.lookForSquarePanels(product))
            .expand((List<KnowledgePanel> e) => e)
            .toList() ??
        <KnowledgePanel>[];
  }

  /// Title card of a knowledge panel, like a one-line score widget, or title.
  Widget? getPanelSummaryWidget(
    final Product product, {
    required final bool isClickable,
    required final bool simplified,
    final bool ignoreEvaluation = false,
    final TextStyle? textStyleOverride,
    final EdgeInsetsGeometry? margin,
    final EdgeInsetsGeometry? padding,
  }) {
    if (titleElement == null) {
      if (simplified) {
        for (final KnowledgePanelElement element
            in elements ?? <KnowledgePanelElement>[]) {
          if (element.elementType == KnowledgePanelElementType.PANEL_GROUP) {
            final List<KnowledgePanel> squarePanels = element
                .lookForSquarePanels(product);
            if (squarePanels.isNotEmpty) {
              return KnowledgePanelSquareCard(
                panels: squarePanels,
                panelsIds: element.panelGroupElement?.panelIds,
                product: product,
              );
            }
          }
        }
      }

      return null;
    }

    switch (titleElement!.type) {
      case TitleElementType.GRADE:
        return simplified
            ? SimplifiedKnowledgePanelTitleCard(
                title: titleElement?.title ?? '',
                subtitle: titleElement!.subtitle,
                iconUrl: titleElement!.iconUrl,
              )
            : ScoreCard.titleElement(
                titleElement: titleElement!,
                isClickable: isClickable,
                margin: margin,
              );

      case null:
      case TitleElementType.PERCENTAGE:
      case TitleElementType.UNKNOWN:
        if (simplified) {
          for (final KnowledgePanelElement element
              in elements ?? <KnowledgePanelElement>[]) {
            if (element.elementType == KnowledgePanelElementType.PANEL_GROUP) {
              final List<KnowledgePanel> squarePanels = element
                  .lookForSquarePanels(product);
              if (squarePanels.isNotEmpty) {
                return KnowledgePanelSquareCard(
                  panels: squarePanels,
                  panelsIds: element.panelGroupElement?.panelIds,
                  product: product,
                );
              }
            }
          }
        }

        return simplified && titleElement!.iconUrl != null
            ? SimplifiedKnowledgePanelTitleCard(
                title: titleElement?.title ?? '',
                subtitle: titleElement!.subtitle,
                iconUrl: titleElement!.iconUrl,
              )
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SMALL_SPACE,
                  end: BALANCED_SPACE,
                ).add(padding ?? EdgeInsetsDirectional.zero),
                child: KnowledgePanelTitleCard(
                  knowledgePanelTitleElement: titleElement!,
                  evaluation: ignoreEvaluation ? null : evaluation,
                  textStyleOverride: textStyleOverride,
                  isClickable: isClickable,
                ),
              );
    }
  }
}
