import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/product/big_redesign/evaluation_extension.dart';
import 'package:smooth_app/pages/product/big_redesign/knowledge_panel_enum.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Simplified widget for knowledge panel.
class KnowledgePanelSimplifiedWidget extends StatelessWidget {
  const KnowledgePanelSimplifiedWidget({
    required this.product,
    required this.knowledgePanelEnum,
    required this.title,
    this.nutrient,
  });

  final Product product;
  final KnowledgePanelEnum knowledgePanelEnum;
  final String title;
  final Nutrient? nutrient;

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
    Evaluation? evaluation = knowledgePanel.evaluation;
    final String? iconUrl = knowledgePanel.titleElement!.iconUrl;
    // TODO(monsieurtanuki): actually cheating in order to get the evaluation.
    if (iconUrl != null) {
      if (iconUrl.contains('moderate')) {
        evaluation = Evaluation.AVERAGE;
      } else if (iconUrl.contains('low')) {
        evaluation = Evaluation.GOOD;
      } else if (iconUrl.contains('high')) {
        evaluation = Evaluation.BAD;
      }
    }
    final String? value =
        _getNutrientValue() ?? _getValue(knowledgePanel.titleElement!.title);
    // TODO(monsieurtanuki): tested with a11y, remove if not relevant
    final IconData? a11yIcon = evaluation.getA11YIconData();
    final Widget? icon;
    if (a11yIcon != null) {
      icon = Icon(
        a11yIcon,
        color: evaluation.getColor(Theme.of(context).brightness),
      );
    } else if (knowledgePanel.titleElement!.iconUrl != null) {
      icon = SvgCache(
        knowledgePanel.titleElement!.iconUrl,
        height: 30,
        width: 30,
      );
    } else {
      icon = null;
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: <Widget>[
                      if (icon != null) icon,
                      if (value != null) Text(value),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              ConstantIcons.instance.getForwardIcon(),
            ),
          ],
        ),
      ),
    );
  }

  // TODO(monsieurtanuki): shouldn't the server do that?
  /// Extract the value inside parenthesis.
  String? _getNutrientValue() {
    if (nutrient == null) {
      return null;
    }
    if (product.nutriments == null) {
      return null;
    }
    final double? value = product.nutriments!.getValue(
      nutrient!,
      PerSize.oneHundredGrams,
    );
    if (value == null) {
      return null;
    }
    final String string = value.toString();
    if (!string.contains('.')) {
      return string;
    }
    return '${_decimalNumberFormat.format(value)}%';
  }

  NumberFormat get _decimalNumberFormat => NumberFormat(
        '##0.0',
        ProductQuery.getLocaleString(),
      );

  // TODO(monsieurtanuki): shouldn't the server do that?
  /// Extract the value inside parenthesis.
  String? _getValue(final String label) {
    final int pos1 = label.lastIndexOf('(');
    if (pos1 < 0) {
      return null;
    }
    final int pos2 = label.lastIndexOf(')');
    if (pos2 < 0) {
      return null;
    }
    if (pos1 >= pos2) {
      return null;
    }
    return label.substring(pos1 + 1, pos2);
  }
}
