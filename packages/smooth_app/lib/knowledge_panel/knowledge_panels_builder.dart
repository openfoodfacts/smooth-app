import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_action_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_image_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_text_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_world_map_card.dart';
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
  }) {
    final String? panelId = panelElement.panelElement?.panelId;
    final KnowledgePanel? rootPanel = panelId == null
        ? null
        : getKnowledgePanel(product, panelId);
    final List<Widget> children = <Widget>[];
    if (rootPanel != null) {
      children.add(KnowledgePanelTitle(title: rootPanel.titleElement!.title));
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

  /// Returns all the panel elements from "root".
  ///
  /// Typically, we get only the "health_card" and "environment_card" panels.
  /// In option, only the one matching [panelId].
  static List<KnowledgePanelElement> getRootPanelElements(
    final Product product, {
    final String? panelId,
  }) {
    final List<KnowledgePanelElement> result = <KnowledgePanelElement>[];
    final KnowledgePanel? root = getKnowledgePanel(product, 'root');
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
    if (panel.elements == null) {
      return false;
    }
    for (final KnowledgePanelElement element in panel.elements!) {
      if (_hasSomethingToDisplay(element: element, product: product)) {
        return true;
      }
    }
    return false;
  }

  /// Returns a padded widget that displays the KP element, or rarely null.
  static Widget? getElementWidget({
    required final KnowledgePanelElement knowledgePanelElement,
    required final Product product,
    required final bool isInitiallyExpanded,
    required final bool isClickable,
    required final bool isTextSelectable,
    required final int position,
  }) {
    final Widget? result = _getElementWidget(
      element: knowledgePanelElement,
      product: product,
      isInitiallyExpanded: isInitiallyExpanded,
      isClickable: isClickable,
      isTextSelectable: isTextSelectable,
      position: position,
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

    if (result is KnowledgePanelTextCard) {
      return result;
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
        child: result,
      );
    }
  }

  /// Returns the widget that displays the KP element, or rarely null.
  ///
  /// cf. [_hasSomethingToDisplay].
  static Widget? _getElementWidget({
    required final KnowledgePanelElement element,
    required final Product product,
    required final bool isInitiallyExpanded,
    required final bool isClickable,
    required final bool isTextSelectable,
    required final int position,
  }) {
    switch (element.elementType) {
      case KnowledgePanelElementType.TEXT:
        return KnowledgePanelTextCard(textElement: element.textElement!);

      case KnowledgePanelElementType.IMAGE:
        return KnowledgePanelImageCard(imageElement: element.imageElement!);

      case KnowledgePanelElementType.PANEL:
        final String panelId = element.panelElement!.panelId;
        final KnowledgePanel? panel = getKnowledgePanel(product, panelId);
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
        );

      case KnowledgePanelElementType.PANEL_GROUP:
        return KnowledgePanelGroupCard(
          groupElement: element.panelGroupElement!,
          product: product,
          isClickable: isClickable,
          isTextSelectable: isTextSelectable,
          position: position,
        );

      case KnowledgePanelElementType.TABLE:
        return KnowledgePanelTableCard(
          tableElement: element.tableElement!,
          isInitiallyExpanded: isInitiallyExpanded,
          product: product,
        );

      case KnowledgePanelElementType.MAP:
        return KnowledgePanelWorldMapCard(element.mapElement!);

      case KnowledgePanelElementType.UNKNOWN:
        return null;

      case KnowledgePanelElementType.ACTION:
        return KnowledgePanelActionCard(element.actionElement!, product);
    }
  }

  /// Returns true if the element has something to display.
  ///
  /// cf. [_getElementWidget].
  static bool _hasSomethingToDisplay({
    required final KnowledgePanelElement element,
    required final Product product,
  }) {
    switch (element.elementType) {
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
        final String panelId = element.panelElement!.panelId;
        final KnowledgePanel? panel = getKnowledgePanel(product, panelId);
        if (panel == null) {
          return false;
        }
        return true;
    }
  }

  /// Title card of a knowledge panel, like a one-line score widget, or title.
  static Widget? getPanelSummaryWidget(
    final KnowledgePanel knowledgePanel, {
    required final bool isClickable,
    final EdgeInsetsGeometry? margin,
    final EdgeInsetsGeometry? padding,
  }) {
    if (knowledgePanel.titleElement == null) {
      return null;
    }

    switch (knowledgePanel.titleElement!.type) {
      case TitleElementType.GRADE:
        return ScoreCard.titleElement(
          titleElement: knowledgePanel.titleElement!,
          isClickable: isClickable,
          margin: margin,
        );

      case null:
      case TitleElementType.UNKNOWN:
        return Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SMALL_SPACE,
          ).add(padding ?? EdgeInsets.zero),
          child: KnowledgePanelTitleCard(
            knowledgePanelTitleElement: knowledgePanel.titleElement!,
            evaluation: knowledgePanel.evaluation,
            isClickable: isClickable,
          ),
        );
    }
  }
}

class KnowledgePanelTitle extends StatelessWidget {
  const KnowledgePanelTitle({required this.title, super.key});

  final String title;

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
