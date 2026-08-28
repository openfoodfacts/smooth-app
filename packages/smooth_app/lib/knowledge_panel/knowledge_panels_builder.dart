import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_element_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_text_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// "Knowledge Panel" builder
class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder._();

  static List<Widget> getChildren(
    BuildContext context, {
    required KnowledgePanelElement panelElement,
    required Product product,
    required bool onboardingMode,
    required bool simplified,
  }) {
    final String? panelId = panelElement.panelElement?.panelId;
    final KnowledgePanel? rootPanel = panelId == null
        ? null
        : getKnowledgePanel(product, panelId);
    final List<Widget> children = <Widget>[];
    if (rootPanel != null) {
      children.add(
        KnowledgePanelTitle(
          title: rootPanel.titleElement!.title ?? '',
          topics: rootPanel.topics,
        ),
      );
      if (rootPanel.elements != null) {
        for (int i = 0; i < rootPanel.elements!.length; i++) {
          final KnowledgePanelElement element = rootPanel.elements![i];
          final Widget? widget = getElementWidget(
            knowledgePanelElement: element,
            product: product,
            isInitiallyExpanded: false,
            isClickable: true,
            isTextSelectable: !onboardingMode,
            position: i,
            simplified: simplified,
          );
          if (widget != null) {
            children.add(widget);
          }
        }
      }
    }
    if (!onboardingMode) {
      if (panelId == 'health_card') {
        final bool nutritionAddOrUpdate =
            product.statesTags?.contains(
              ProductState.NUTRITION_FACTS_COMPLETED.toBeCompletedTag,
            ) ??
            false;
        if (nutritionAddOrUpdate) {
          if (AddNutritionButton.acceptsNutritionFacts(product)) {
            children.add(AddNutritionButton(product));
          }
        }

        final bool needEditIngredients =
            context.read<UserPreferences>().getFlag(
              UserPreferencesDevMode.userPreferencesFlagEditIngredients,
            ) ??
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
        'Unexpected empty panel data for product "${product.barcode}" and panelId "$panelId"',
      );
    }
    return children;
  }

  static bool supportsSimplifiedPanels(final Product product) =>
      (product.productType ?? ProductType.food) == ProductType.food;

  static bool needsSimplifiedPanelsRefresh(final Product product) {
    if (supportsSimplifiedPanels(product)) {
      return getRootKnowledgePanel(product, simplified: true) == null;
    }
    return false;
  }

  /// Returns all the panel elements from "root".
  ///
  /// Typically, we get only the "health_card" and "environment_card" panels.
  /// In option, only the one matching [panelId].
  static List<KnowledgePanelElement> getRootPanelElements(
    final Product product, {
    required final bool simplified,
    final String? panelId,
  }) {
    final List<KnowledgePanelElement> result = <KnowledgePanelElement>[];
    final KnowledgePanel? root = getRootKnowledgePanel(
      product,
      simplified: simplified,
    );

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

  /// Returns the root KP.
  static KnowledgePanel? getRootKnowledgePanel(
    final Product product, {
    required final bool simplified,
  }) => getKnowledgePanel(product, simplified ? 'simplified_root' : 'root');

  /// Returns the KP that matches the [panelId].
  static KnowledgePanel? getKnowledgePanel(
    final Product product,
    final String panelId,
  ) => product.knowledgePanels?.panelIdToPanelMap[panelId];

  /// Returns the unique "root" panel element that matches [panelId], or `null`.
  static KnowledgePanelElement? getRootPanelElement(
    final Product product,
    final String panelId,
  ) {
    final List<KnowledgePanelElement> elements = getRootPanelElements(
      product,
      panelId: panelId,
      simplified: false,
    );
    if (elements.length != 1) {
      return null;
    }
    return elements.first;
  }

  /// Returns true if there are elements to display for that panel.
  static bool hasSomethingToDisplay(
    final Product product,
    final String panelId,
  ) {
    final KnowledgePanel panel = KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      panelId,
    )!;
    return panel.hasSomethingToDisplay(product);
  }

  /// Returns a padded widget that displays the KP element, or rarely null.
  static Widget? getElementWidget({
    required final KnowledgePanelElement knowledgePanelElement,
    required final Product product,
    required final bool isInitiallyExpanded,
    required final bool isClickable,
    required final bool isTextSelectable,
    required final int position,
    required final bool simplified,
  }) {
    final Widget? result = knowledgePanelElement.getElementWidget(
      product: product,
      isInitiallyExpanded: isInitiallyExpanded,
      isClickable: isClickable,
      isTextSelectable: isTextSelectable,
      position: position,
      simplified: simplified,
    );
    if (result == null) {
      return null;
    }
    if (<KnowledgePanelElementType>[
      KnowledgePanelElementType.PANEL,
      KnowledgePanelElementType.PANEL_GROUP,
    ].contains(knowledgePanelElement.elementType)) {
      return result;
    }

    if (result is KnowledgePanelTextCard ||
        knowledgePanelElement.elementType == KnowledgePanelElementType.TABLE) {
      return result;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
      child: result,
    );
  }
}

class KnowledgePanelTitle extends StatelessWidget {
  const KnowledgePanelTitle({required this.title, this.topics, super.key});

  final String title;
  final List<String>? topics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: VERY_SMALL_SPACE,
      ),
      child: Text(title, style: Theme.of(context).textTheme.displaySmall),
    );
  }
}
