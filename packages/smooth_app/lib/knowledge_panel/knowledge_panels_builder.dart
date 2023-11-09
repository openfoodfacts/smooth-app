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
    final KnowledgePanel? rootPanel =
        panelId == null ? null : getKnowledgePanel(product, panelId);
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
      if (rootPanel.elements != null) {
        for (final KnowledgePanelElement element in rootPanel.elements!) {
          final Widget? widget = getElementWidget(
            knowledgePanelElement: element,
            product: product,
            isInitiallyExpanded: false,
          );
          if (widget != null) {
            children.add(widget);
          }
        }
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
  ) =>
      product.knowledgePanels?.panelIdToPanelMap[panelId];

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

  /// Returns a padded widget that displays the KP element, or rarely null.
  static Widget? getElementWidget({
    required final KnowledgePanelElement knowledgePanelElement,
    required final Product product,
    required final bool isInitiallyExpanded,
  }) {
    final Widget? result = _getElementWidget(
      element: knowledgePanelElement,
      product: product,
      isInitiallyExpanded: isInitiallyExpanded,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
      child: result,
    );
  }

  /// Returns the widget that displays the KP element, or rarely null.
  static Widget? _getElementWidget({
    required final KnowledgePanelElement element,
    required final Product product,
    required final bool isInitiallyExpanded,
  }) {
    switch (element.elementType) {
      case KnowledgePanelElementType.TEXT:
        return KnowledgePanelTextCard(
          textElement: element.textElement!,
        );

      case KnowledgePanelElementType.IMAGE:
        return KnowledgePanelImageCard(
          imageElement: element.imageElement!,
        );

      case KnowledgePanelElementType.PANEL:
        final String panelId = element.panelElement!.panelId;
        final KnowledgePanel? panel = getKnowledgePanel(product, panelId);
        if (panel == null) {
          // happened in https://github.com/openfoodfacts/smooth-app/issues/2682
          // due to some inconsistencies in the data sent by the server
          Logs.w(
            'unknown panel "$panelId" for barcode "${product.barcode}"',
          );
          return null;
        }
        return KnowledgePanelCard(
          panelId: panelId,
          product: product,
        );

      case KnowledgePanelElementType.PANEL_GROUP:
        return KnowledgePanelGroupCard(
          groupElement: element.panelGroupElement!,
          product: product,
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
        return KnowledgePanelActionCard(
          element.actionElement!,
          product,
        );

      default:
        Logs.e('unexpected element type: ${element.elementType}');
        return null;
    }
  }

  /// Title card of a knowledge panel, like a one-line score widget, or title.
  static Widget? getPanelSummaryWidget(
    final KnowledgePanel knowledgePanel, {
    required final bool isClickable,
    final EdgeInsets? margin,
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
          padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
          child: KnowledgePanelTitleCard(
            knowledgePanelTitleElement: knowledgePanel.titleElement!,
            evaluation: knowledgePanel.evaluation,
            isClickable: isClickable,
          ),
        );
    }
  }
}
