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
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_text_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_title_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_world_map_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/new_knowledge_panel_title_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// "Knowledge Panel" builder
class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder._();

  static const String _simplifiedRootPanelId = 'simplified_root';

  static List<Widget> getChildren(
    BuildContext context, {
    required KnowledgePanelElement panelElement,
    required Product product,
    required bool onboardingMode,
    bool simplified = false,
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

  static List<KnowledgePanel> lookForSquarePanels({
    required final KnowledgePanelElement element,
    required final Product product,
  }) {
    if (element.elementType == KnowledgePanelElementType.PANEL_GROUP) {
      final List<String>? panelIds = element.panelGroupElement?.panelIds;
      final List<KnowledgePanel> result = <KnowledgePanel>[];

      for (final String panelId in panelIds ?? <String>[]) {
        final KnowledgePanel? panel = getKnowledgePanel(product, panelId);

        if (panel == null) {
          continue;
        }

        result.addAll(getSquarePanels(panel: panel, product: product));
      }

      return result;
    }

    final KnowledgePanel? panel = getKnowledgePanel(
      product,
      element.panelElement?.panelId ?? '',
    );

    if (panel == null) {
      return <KnowledgePanel>[];
    }

    return getSquarePanels(panel: panel, product: product);
  }

  static List<KnowledgePanel> getSquarePanels({
    required final KnowledgePanel panel,
    required final Product product,
  }) {
    if ((panel.halfWidthOnMobile ?? false) || (panel.evaluation != null)) {
      return <KnowledgePanel>[panel];
    }

    return panel.elements
            ?.map(
              (KnowledgePanelElement e) =>
                  lookForSquarePanels(element: e, product: product),
            )
            .expand((List<KnowledgePanel> e) => e)
            .toList() ??
        <KnowledgePanel>[];
  }

  static bool hasSimplifiedPanels(final Product product) =>
      getKnowledgePanel(product, _simplifiedRootPanelId) != null;

  /// Returns all the panel elements from "root".
  ///
  /// Typically, we get only the "health_card" and "environment_card" panels.
  /// In option, only the one matching [panelId].
  static List<KnowledgePanelElement> getRootPanelElements(
    final Product product, {
    final String? panelId,
    final bool simplified = false,
  }) {
    final List<KnowledgePanelElement> result = <KnowledgePanelElement>[];
    final KnowledgePanel? root = getKnowledgePanel(
      product,
      simplified ? _simplifiedRootPanelId : 'root',
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
    final bool simplified = false,
  }) {
    final Widget? result = _getElementWidget(
      element: knowledgePanelElement,
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
    final bool simplified = false,
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
          simplified: simplified,
        );

      case KnowledgePanelElementType.PANEL_GROUP:
        if (simplified) {
          final List<KnowledgePanel> squarePanels = <KnowledgePanel>[];
          for (final String panelId in element.panelGroupElement!.panelIds) {
            final KnowledgePanel? panel =
                KnowledgePanelsBuilder.getKnowledgePanel(product, panelId);
            if (panel != null && (panel.halfWidthOnMobile ?? false)) {
              squarePanels.add(panel);
            }
          }

          if (squarePanels.isNotEmpty) {
            return KnowledgePanelSquareCard(
              panels: squarePanels,
              product: product,
            );
          }
        }

        return KnowledgePanelGroupCard(
          groupElement: element.panelGroupElement!,
          product: product,
          isClickable: isClickable,
          isTextSelectable: isTextSelectable,
          position: position,
          simplified: simplified,
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
    final KnowledgePanel knowledgePanel,
    final Product product, {
    required final bool isClickable,
    final bool ignoreEvaluation = false,
    final TextStyle? textStyleOverride,
    final EdgeInsetsGeometry? margin,
    final EdgeInsetsGeometry? padding,
    final bool simplified = true,
  }) {
    if (knowledgePanel.titleElement == null) {
      if (simplified) {
        for (final KnowledgePanelElement element
            in knowledgePanel.elements ?? <KnowledgePanelElement>[]) {
          if (element.elementType == KnowledgePanelElementType.PANEL_GROUP) {
            final List<KnowledgePanel> squarePanels = lookForSquarePanels(
              element: element,
              product: product,
            );
            if (squarePanels.isNotEmpty) {
              return KnowledgePanelSquareCard(
                panels: squarePanels,
                product: product,
              );
            }
          }
        }
      }

      return null;
    }

    switch (knowledgePanel.titleElement!.type) {
      case TitleElementType.GRADE:
        return simplified
            ? SimplifiedKnowledgePanelTitleCard(
                title: knowledgePanel.titleElement?.title ?? '',
                subtitle: knowledgePanel.titleElement!.subtitle,
                iconUrl: knowledgePanel.titleElement!.iconUrl,
              )
            : ScoreCard.titleElement(
                titleElement: knowledgePanel.titleElement!,
                isClickable: isClickable,
                margin: margin,
              );

      case null:
      case TitleElementType.PERCENTAGE:
      case TitleElementType.UNKNOWN:
        if (simplified) {
          for (final KnowledgePanelElement element
              in knowledgePanel.elements ?? <KnowledgePanelElement>[]) {
            if (element.elementType == KnowledgePanelElementType.PANEL_GROUP) {
              final List<KnowledgePanel> squarePanels = lookForSquarePanels(
                element: element,
                product: product,
              );
              if (squarePanels.isNotEmpty) {
                return KnowledgePanelSquareCard(
                  panels: squarePanels,
                  product: product,
                );
              }
            }
          }
        }

        return simplified && knowledgePanel.titleElement!.iconUrl != null
            ? SimplifiedKnowledgePanelTitleCard(
                title: knowledgePanel.titleElement?.title ?? '',
                subtitle: knowledgePanel.titleElement!.subtitle,
                iconUrl: knowledgePanel.titleElement!.iconUrl,
              )
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SMALL_SPACE,
                  end: BALANCED_SPACE,
                ).add(padding ?? EdgeInsetsDirectional.zero),
                child: KnowledgePanelTitleCard(
                  knowledgePanelTitleElement: knowledgePanel.titleElement!,
                  evaluation: ignoreEvaluation
                      ? null
                      : knowledgePanel.evaluation,
                  textStyleOverride: textStyleOverride,
                  isClickable: isClickable,
                ),
              );
    }
  }

  static Color? getColorFromEvaluation(
    BuildContext context,
    Evaluation? evaluation,
  ) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return switch (evaluation) {
      Evaluation.BAD => theme.error,
      Evaluation.GOOD => theme.success,
      Evaluation.AVERAGE => theme.warning,
      _ => null,
    };
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
