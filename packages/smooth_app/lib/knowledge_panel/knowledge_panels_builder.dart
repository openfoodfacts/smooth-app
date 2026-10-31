import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_element_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panel_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_text_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// "Knowledge Panel" builder
class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder._();

  static const String _healthCardId = 'health_card';
  static const String _simplifiedHealthCardId = 'health_card_simplified';

  /// Panels of the full health card that we add to the simplified one.
  ///
  /// Otherwise they would be two levels below (tab, then "learn more"), and so
  /// would the "expand" preferences, cf. [KnowledgePanelCard.getExpandFlagTag].
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/7728
  static const List<String> _simplifiedHealthCardExtraPanelIds = <String>[
    KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
    KnowledgePanelCard.PANEL_INGREDIENTS_ID,
  ];

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
      final List<KnowledgePanelElement>? elements =
          panelId == _simplifiedHealthCardId
          ? _getSimplifiedHealthCardElements(product, rootPanel)
          : rootPanel.elements;
      if (elements != null) {
        for (int i = 0; i < elements.length; i++) {
          final KnowledgePanelElement element = elements[i];
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
      if (panelId == _healthCardId || panelId == _simplifiedHealthCardId) {
        final bool nutritionAddOrUpdate =
            product.statesTags?.contains(
              ProductState.NUTRITION_FACTS_COMPLETED.toBeCompletedTag,
            ) ??
            false;
        if (nutritionAddOrUpdate) {
          if (AddNutritionButton.acceptsNutritionFacts(product)) {
            children.add(_getPaddedButton(AddNutritionButton(product)));
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
            _getPaddedButton(
              AddOcrButton(
                product: product,
                editor: ProductFieldOcrIngredientEditor(),
              ),
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

  /// Returns the [button] with the same side padding as the KP action buttons.
  static Widget _getPaddedButton(final Widget button) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
    child: button,
  );

  /// Returns the elements of the simplified health card, with the extra panels.
  ///
  /// The extra panels are added right after the nutrient levels, as a group,
  /// unless they are missing or already displayed.
  /// cf. [_simplifiedHealthCardExtraPanelIds].
  static List<KnowledgePanelElement> _getSimplifiedHealthCardElements(
    final Product product,
    final KnowledgePanel panel,
  ) {
    final List<KnowledgePanelElement> elements = <KnowledgePanelElement>[
      ...?panel.elements,
    ];
    final Set<String> displayedPanelIds = _getDisplayedPanelIds(
      product,
      elements,
    );
    final List<String> extraPanelIds = <String>[
      for (final String panelId in _simplifiedHealthCardExtraPanelIds)
        if (!displayedPanelIds.contains(panelId) &&
            getKnowledgePanel(product, panelId) != null)
          panelId,
    ];
    if (extraPanelIds.isEmpty) {
      return elements;
    }
    final int nutrientLevelsIndex = elements.indexWhere(
      (final KnowledgePanelElement element) =>
          element.getPanelIds().contains('nutrient_levels'),
    );
    elements.insert(
      nutrientLevelsIndex < 0 ? elements.length : nutrientLevelsIndex + 1,
      KnowledgePanelElement(
        elementType: KnowledgePanelElementType.PANEL_GROUP,
        panelGroupElement: KnowledgePanelPanelGroupElement(
          title: null,
          panelIds: extraPanelIds,
        ),
      ),
    );
    return elements;
  }

  /// Returns the ids of the panels displayed by [elements].
  ///
  /// That includes the panels displayed inside expanded panels, but not the
  /// ones inside collapsed panels.
  static Set<String> _getDisplayedPanelIds(
    final Product product,
    final Iterable<KnowledgePanelElement> elements,
  ) {
    final Set<String> result = <String>{};
    void addPanelIds(final Iterable<KnowledgePanelElement> children) {
      for (final KnowledgePanelElement child in children) {
        for (final String panelId in child.getPanelIds()) {
          // already seen, which also prevents infinite loops
          if (!result.add(panelId)) {
            continue;
          }
          final KnowledgePanel? panel = getKnowledgePanel(product, panelId);
          if (panel != null && panel.expanded == true) {
            addPanelIds(panel.elements ?? const <KnowledgePanelElement>[]);
          }
        }
      }
    }

    addPanelIds(elements);
    return result;
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
