import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_title.dart';

class KnowledgePanelGroupCard extends StatelessWidget {
  const KnowledgePanelGroupCard({
    required this.groupElement,
    required this.product,
    required this.isClickable,
    required this.isTextSelectable,
    required this.position,
    this.simplified = false,
  });

  final KnowledgePanelPanelGroupElement groupElement;
  final Product product;
  final bool isClickable;
  final bool isTextSelectable;
  final int position;
  final bool simplified;

  @override
  Widget build(BuildContext context) {
    final Widget child = Provider<KnowledgePanelPanelGroupElement>(
      lazy: true,
      create: (_) => groupElement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (groupElement.title != null && groupElement.title!.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: position > 0 ? MEDIUM_SPACE : 0.0,
              ),
              child: ProductPageTitle(label: groupElement.title!),
            ),
          for (final String panelId in groupElement.panelIds)
            KnowledgePanelCard(
              panelId: panelId,
              product: product,
              isClickable: isClickable,
              simplified: simplified,
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
