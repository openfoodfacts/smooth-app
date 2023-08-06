import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/services/smooth_services.dart';

// TODO(monsieurtanuki): rename without "Widget", like the file: KnowledgePanelsBuilder?
/// "Knowledge Panel" widget.
class KnowledgePanelWidget {
  const KnowledgePanelWidget._();

  static List<Widget> getChildren(
    BuildContext context, {
    required KnowledgePanelElement panelElement,
    required Product product,
    required bool onboardingMode,
  }) {
    final String? panelId = panelElement.panelElement?.panelId;
    final KnowledgePanel? rootPanel = panelId == null
        ? null
        : KnowledgePanelWidget.getKnowledgePanel(product, panelId);
    // [knowledgePanelElementWidgets] are a set of widgets inside the root panel.
    final List<Widget> children = <Widget>[];
    if (rootPanel != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: VERY_SMALL_SPACE,
            horizontal: SMALL_SPACE,
          ),
          child: Text(
            rootPanel.titleElement!.title,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      );
      for (final KnowledgePanelElement knowledgePanelElement
          in rootPanel.elements ?? <KnowledgePanelElement>[]) {
        children.add(
          KnowledgePanelElementCard(
            knowledgePanelElement: knowledgePanelElement,
            product: product,
            isInitiallyExpanded: false,
          ),
        );
      }
    }
    if (!onboardingMode) {
      if (panelId == 'health_card') {
        final bool nutritionAddOrUpdate = product.statesTags?.contains(
                ProductState.NUTRITION_FACTS_COMPLETED.toBeCompletedTag) ??
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
          children.add(
            AddOcrButton(
              product: product,
              editor: ProductFieldOcrIngredientEditor(),
            ),
          );
        }
      }
    }
    if (children.isEmpty) {
      Logs.e(
          'Unexpected empty panel data for product "${product.barcode}" and panelId "$panelId"');
    }
    return children;
  }

  /// Returns all the panel elements, in option only the one matching [panelId].
  static List<KnowledgePanelElement> getPanelElements(
    final Product product, {
    final String? panelId,
  }) {
    final List<KnowledgePanelElement> result = <KnowledgePanelElement>[];
    final KnowledgePanel? root =
        KnowledgePanelWidget.getKnowledgePanel(product, 'root');
    if (root == null) {
      return result;
    }
    if (root.elements == null) {
      return result;
    }
    for (final KnowledgePanelElement panelElement in root.elements!) {
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

  static KnowledgePanel? getKnowledgePanel(
    final Product product,
    final String panelId,
  ) =>
      product.knowledgePanels?.panelIdToPanelMap[panelId];

  /// Returns the unique panel element that matches [panelId], or `null`.
  static KnowledgePanelElement? getPanelElement(
    final Product product,
    final String panelId,
  ) {
    final List<KnowledgePanelElement> elements = getPanelElements(
      product,
      panelId: panelId,
    );
    if (elements.length != 1) {
      return null;
    }
    return elements.first;
  }
}
