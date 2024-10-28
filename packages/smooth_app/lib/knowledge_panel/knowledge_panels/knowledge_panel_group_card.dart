import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelGroupCard extends StatelessWidget {
  const KnowledgePanelGroupCard({
    required this.groupElement,
    required this.product,
    required this.isClickable,
  });

  final KnowledgePanelPanelGroupElement groupElement;
  final Product product;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        themeData.extension<SmoothColorsThemeExtension>()!;

    return Provider<KnowledgePanelPanelGroupElement>(
      lazy: true,
      create: (_) => groupElement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (groupElement.title != null && groupElement.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
              child: Semantics(
                explicitChildNodes: true,
                child: Text(
                  groupElement.title!,
                  style: themeData.textTheme.titleSmall!.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: context.lightTheme()
                        ? themeExtension.primaryUltraBlack
                        : themeExtension.primaryLight,
                  ),
                ),
              ),
            ),
          for (final String panelId in groupElement.panelIds)
            KnowledgePanelCard(
              panelId: panelId,
              product: product,
              isClickable: isClickable,
            )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('groupElement', groupElement.title));
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
    properties.add(IterableProperty<String>('panelIds', groupElement.panelIds));
  }
}
