import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/widgets/loading_dialog.dart';

/// Builds "knowledge panels" panels.
///
/// Panels display large data like all health data or environment data.
class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder();

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
          dummyAddButton(
            nutritionAddOrUpdate
                ? appLocalizations.score_add_missing_nutrition_facts
                : appLocalizations.score_update_nutrition_facts,
            iconData: nutritionAddOrUpdate ? Icons.add : Icons.edit,
            onPressed: () async {
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              final OrderedNutrientsCache cache =
                  OrderedNutrientsCache(localDatabase);
              final OrderedNutrients? orderedNutrients = await cache.get() ??
                  await LoadingDialog.run<OrderedNutrients>(
                    context: context,
                    future: cache.download(),
                  );
              if (orderedNutrients == null) {
                await LoadingDialog.error(context: context);
                return;
              }
              await Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => NutritionPageLoaded(
                    product,
                    orderedNutrients,
                  ),
                ),
              );
              // TODO(monsieurtanuki): refresh the data if changed
            },
          ),
        );
        if (product.statesTags?.contains('en:ingredients-to-be-completed') ??
            false) {
          knowledgePanelElementWidgets.add(
            dummyAddButton(
              appLocalizations.score_add_missing_ingredients,
            ),
          );
        }
      }
    }
    return Column(children: knowledgePanelElementWidgets);
  }
}
