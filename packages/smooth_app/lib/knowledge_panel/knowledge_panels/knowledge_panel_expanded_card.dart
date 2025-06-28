import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelExpandedCard extends StatelessWidget {
  const KnowledgePanelExpandedCard({
    required this.panelId,
    required this.product,
    required this.isInitiallyExpanded,
    required this.isClickable,
  });

  final Product product;
  final String panelId;
  final bool isInitiallyExpanded;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanel panel = KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      panelId,
    )!;

    final List<Widget> elementWidgets = <Widget>[];

    final List<Widget>? summaryWidgets = _getSummary(panel);
    if (summaryWidgets != null) {
      elementWidgets.addAll(summaryWidgets);
    }

    if (panel.elements != null) {
      for (int i = 0; i < panel.elements!.length; i++) {
        final KnowledgePanelElement element = panel.elements![i];
        final Widget? elementWidget = KnowledgePanelsBuilder.getElementWidget(
          knowledgePanelElement: element,
          product: product,
          isInitiallyExpanded: isInitiallyExpanded,
          isClickable: isClickable,
          isTextSelectable: true,
          position: i,
        );
        if (elementWidget != null) {
          elementWidgets.add(
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: VERY_SMALL_SPACE,
                start: isInitiallyExpanded ? MEDIUM_SPACE : 0.0,
                end: isInitiallyExpanded ? MEDIUM_SPACE : 0.0,
              ),
              child: elementWidget,
            ),
          );
        }
      }
    }
    return Provider<KnowledgePanel>(
      lazy: true,
      create: (_) => panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: elementWidgets,
      ),
    );
  }

  List<Widget>? _getSummary(KnowledgePanel panel) {
    final Widget? summary = KnowledgePanelsBuilder.getPanelSummaryWidget(
      panel,
      isClickable: false,
    );

    if (summary != null) {
      if (isInitiallyExpanded) {
        if (summary is ScoreCard) {
          return <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MEDIUM_SPACE,
              ),
              child: summary,
            ),
          ];
        } else {
          return <Widget>[
            _KnowledgePanelSummaryCardTitle(child: summary),
            const SizedBox(height: SMALL_SPACE),
          ];
        }
      } else {
        return <Widget>[summary];
      }
    }

    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('panelId', panelId));
    properties.add(
      DiagnosticsProperty<bool>('initiallyExpanded', isInitiallyExpanded),
    );
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
  }
}

/// Force a background around a summary Widget
class _KnowledgePanelSummaryCardTitle extends StatelessWidget {
  const _KnowledgePanelSummaryCardTitle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.lightTheme()
            ? extension.primaryMedium
            : extension.primaryUltraBlack,
        borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: SMALL_SPACE,
          horizontal: MEDIUM_SPACE,
        ),
        child: DefaultTextStyle.merge(
          child: child,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
