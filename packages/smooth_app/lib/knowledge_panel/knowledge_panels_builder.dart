import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_ingredients_button.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';

/// "Knowledge Panel" widget.
class KnowledgePanelWidget extends StatelessWidget {
  const KnowledgePanelWidget({
    required this.panelElement,
    required this.knowledgePanels,
    required this.product,
    required this.onboardingMode,
  });

  final KnowledgePanelElement panelElement;
  final KnowledgePanels knowledgePanels;
  final Product product;
  final bool onboardingMode;

  @override
  Widget build(BuildContext context) {
    final String panelId = panelElement.panelElement!.panelId;
    final KnowledgePanel rootPanel =
        knowledgePanels.panelIdToPanelMap[panelId]!;
    // [knowledgePanelElementWidgets] are a set of widgets inside the root panel.
    final List<Widget> children = <Widget>[];
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: VERY_SMALL_SPACE),
        child: Text(
          rootPanel.titleElement!.title,
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
    for (final KnowledgePanelElement knowledgePanelElement
        in rootPanel.elements ?? <KnowledgePanelElement>[]) {
      children.add(
        KnowledgePanelElementCard(
          knowledgePanelElement: knowledgePanelElement,
          allPanels: knowledgePanels,
          product: product,
          isInitiallyExpanded: false,
        ),
      );
    }
    if (!onboardingMode) {
      if (panelId == 'health_card') {
        final bool nutritionAddOrUpdate = product.statesTags
                ?.contains('en:nutrition-facts-to-be-completed') ??
            false;
        if (nutritionAddOrUpdate) {
          children.add(AddNutritionButton(product));
        }

        final bool needEditIngredients = context
                .read<UserPreferences>()
                .getFlag(UserPreferencesDevMode
                    .userPreferencesFlagEditIngredients) ??
            false;
        if ((product.ingredientsText == null ||
                product.ingredientsText!.isEmpty) &&
            needEditIngredients) {
          // When the flag is removed, this should be the following:
          // if (product.statesTags?.contains('en:ingredients-to-be-completed') ?? false) {
          children.add(AddIngredientsButton(product));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Returns all the panel elements, in option only the one matching [panelId].
  static List<KnowledgePanelElement> getPanelElements(
    final KnowledgePanels knowledgePanels, {
    final String? panelId,
  }) {
    final List<KnowledgePanelElement> result = <KnowledgePanelElement>[];
    if (knowledgePanels.panelIdToPanelMap['root'] == null) {
      return result;
    }
    if (knowledgePanels.panelIdToPanelMap['root']!.elements == null) {
      return result;
    }
    for (final KnowledgePanelElement panelElement
        in knowledgePanels.panelIdToPanelMap['root']!.elements!) {
      if (panelElement.elementType != KnowledgePanelElementType.PANEL) {
        continue;
      }
      // no filter
      if (panelId == null) {
        result.add(panelElement);
      } else {
        if (panelId == panelElement.panelElement!.panelId) {
          result.add(panelElement);
          return result;
        }
      }
    }
    return result;
  }

  /// Returns the unique panel element that matches [panelId], or `null`.
  static KnowledgePanelElement? getPanelElement(
    final KnowledgePanels knowledgePanels,
    final String panelId,
  ) {
    final List<KnowledgePanelElement> elements = getPanelElements(
      knowledgePanels,
      panelId: panelId,
    );
    if (elements.length != 1) {
      return null;
    }
    return elements.first;
  }
}
