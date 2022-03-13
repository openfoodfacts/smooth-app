import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';

/// Builds "knowledge panels" panels.
///
/// Panels display large data like all health data or environment data.
class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder({this.setState});

  /// Would for instance refresh the product page.
  final VoidCallback? setState;

  /// Builds all panels.
  ///
  /// Typical use case: product page.
  List<Widget> buildAll(
    KnowledgePanels knowledgePanels, {
    final Product? product,
    final BuildContext? context,
  }) {
    final List<Widget> rootPanelWidgets = <Widget>[];
    if (knowledgePanels.panelIdToPanelMap['root'] == null) {
      return rootPanelWidgets;
    }
    if (knowledgePanels.panelIdToPanelMap['root']!.elements == null) {
      return rootPanelWidgets;
    }
    for (final KnowledgePanelElement panelElement
        in knowledgePanels.panelIdToPanelMap['root']!.elements!) {
      if (panelElement.elementType != KnowledgePanelElementType.PANEL) {
        continue;
      }
      rootPanelWidgets.add(
        _buildPanel(
          panelElement,
          knowledgePanels,
          context: context,
          product: product,
        ),
      );
    }
    return rootPanelWidgets;
  }

  /// Builds a single panel, if available.
  ///
  /// Typical use case so far: onboarding, where we focus on one panel only.
  Widget? buildSingle(
    final KnowledgePanels knowledgePanels,
    final String panelId,
  ) {
    if (knowledgePanels.panelIdToPanelMap['root'] == null) {
      return null;
    }
    if (knowledgePanels.panelIdToPanelMap['root']!.elements == null) {
      return null;
    }
    for (final KnowledgePanelElement panelElement
        in knowledgePanels.panelIdToPanelMap['root']!.elements!) {
      if (panelElement.elementType != KnowledgePanelElementType.PANEL) {
        continue;
      }
      if (panelId != panelElement.panelElement!.panelId) {
        continue;
      }
      return _buildPanel(panelElement, knowledgePanels);
    }
    return null;
  }

  Widget _buildPanel(
    final KnowledgePanelElement panelElement,
    final KnowledgePanels knowledgePanels, {
    final Product? product,
    final BuildContext? context,
  }) {
    final String panelId = panelElement.panelElement!.panelId;
    final KnowledgePanel rootPanel =
        knowledgePanels.panelIdToPanelMap[panelId]!;
    // [knowledgePanelElementWidgets] are a set of widgets inside the root panel.
    final List<Widget> knowledgePanelElementWidgets = <Widget>[];
    for (final KnowledgePanelElement knowledgePanelElement
        in rootPanel.elements ?? <KnowledgePanelElement>[]) {
      knowledgePanelElementWidgets.add(KnowledgePanelElementCard(
        knowledgePanelElement: knowledgePanelElement,
        allPanels: knowledgePanels,
      ));
    }
    if (product != null && context != null) {
      if (panelId == 'health_card') {
        final bool nutritionAddOrUpdate = product.statesTags
                ?.contains('en:nutrition-facts-to-be-completed') ??
            false;
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        knowledgePanelElementWidgets.add(
          addPanelButton(
            nutritionAddOrUpdate
                ? appLocalizations.score_add_missing_nutrition_facts
                : appLocalizations.score_update_nutrition_facts,
            iconData: nutritionAddOrUpdate ? Icons.add : Icons.edit,
            onPressed: () async {
              final OrderedNutrientsCache? cache =
                  await OrderedNutrientsCache.getCache(context);
              if (cache == null) {
                return;
              }
              final bool? refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => NutritionPageLoaded(
                    product,
                    cache.orderedNutrients,
                  ),
                ),
              );
              if (refreshed ?? false) {
                setState?.call();
              }
              // TODO(monsieurtanuki): refresh the data if changed
            },
          ),
        );
        if (product.statesTags?.contains('en:ingredients-to-be-completed') ??
            false) {
          knowledgePanelElementWidgets.add(
            addPanelButton(
              appLocalizations.score_add_missing_ingredients,
              onPressed: () {},
            ),
          );
        }
      }
    }
    return Column(children: knowledgePanelElementWidgets);
  }
}
