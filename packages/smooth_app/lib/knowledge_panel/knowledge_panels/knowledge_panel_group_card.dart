import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelGroupCard extends StatelessWidget {
  const KnowledgePanelGroupCard({
    required this.groupElement,
    required this.product,
    required this.isClickable,
    required this.isTextSelectable,
    required this.position,
  });

  final KnowledgePanelPanelGroupElement groupElement;
  final Product product;
  final bool isClickable;
  final bool isTextSelectable;
  final int position;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final Widget child = Provider<KnowledgePanelPanelGroupElement>(
      lazy: true,
      create: (_) => groupElement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (groupElement.title != null && groupElement.title!.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: position == 0 ? VERY_SMALL_SPACE : VERY_LARGE_SPACE,
              ),
              child: Semantics(
                explicitChildNodes: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: lightTheme
                        ? themeExtension.primaryLight
                        : themeExtension.primarySemiDark,
                    borderRadius: ANGULAR_BORDER_RADIUS,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: MEDIUM_SPACE,
                      vertical: SMALL_SPACE,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          SmoothModalSheetHeaderPrefixIndicator(
                            color: lightTheme
                                ? themeExtension.primaryUltraBlack
                                : themeExtension.primaryLight,
                          ),
                          const SizedBox(width: SMALL_SPACE),
                          Text(
                            groupElement.title!,
                            textAlign: TextAlign.start,
                            style: themeData.textTheme.titleSmall!.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: lightTheme
                                  ? themeExtension.primaryUltraBlack
                                  : themeExtension.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          for (final String panelId in groupElement.panelIds)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: VERY_SMALL_SPACE,
              ),
              child: KnowledgePanelCard(
                panelId: panelId,
                product: product,
                isClickable: isClickable,
              ),
            ),
        ],
      ),
    );

    if (isTextSelectable) {
      return SelectionArea(child: child);
    } else {
      return child;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('groupElement', groupElement.title));
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
    properties.add(IterableProperty<String>('panelIds', groupElement.panelIds));
  }
}
