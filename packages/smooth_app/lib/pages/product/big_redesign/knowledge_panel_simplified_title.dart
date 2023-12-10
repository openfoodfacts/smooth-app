import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_enum.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Full width title for a simplified knowledge panel.
class KnowledgePanelSimplifiedTitle extends StatelessWidget {
  const KnowledgePanelSimplifiedTitle({
    required this.product,
    required this.knowledgePanelEnum,
    required this.title,
  });

  final Product product;
  final KnowledgePanelEnum knowledgePanelEnum;
  final String title;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanel? knowledgePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      knowledgePanelEnum.id,
    );
    if (knowledgePanel == null || knowledgePanel.titleElement == null) {
      return EMPTY_WIDGET;
    }
    return SmoothCard(
      child: InkWell(
        onTap: () async => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => KnowledgePanelPage(
              panelId: knowledgePanelEnum.id,
              product: product,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.displaySmall),
                  Text(knowledgePanel.titleElement!.title),
                ],
              ),
            ),
            if (knowledgePanel.titleElement!.iconUrl != null)
              SvgCache(
                knowledgePanel.titleElement!.iconUrl,
                height: 60,
              ),
            Icon(ConstantIcons.instance.getForwardIcon()),
          ],
        ),
      ),
    );
  }
}
