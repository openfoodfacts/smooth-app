import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class HealthKnowledgePanel extends StatelessWidget {
  const HealthKnowledgePanel({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanel nutriscorePanel =
        KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      'nutriscore_2023',
    )!;

    final List<KnowledgePanel> squarePanels = <String>[
      'nutrient_level_fat',
      'nutrient_level_saturated-fat',
      'nutrient_level_sugars',
      'nutrient_level_salt',
    ]
        .map((String panelId) => KnowledgePanelsBuilder.getKnowledgePanel(
              product,
              panelId,
            )!)
        .toList();

    final KnowledgePanel novaPanel = KnowledgePanelsBuilder.getKnowledgePanel(
      product,
      'nova',
    )!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NewKnowledgePanelTitleCard(
          title: 'Qualité nutritionnelle',
          subtitle: nutriscorePanel.titleElement?.subtitle ?? '',
          iconUrl: nutriscorePanel.titleElement?.iconUrl,
        ),
        KnowledgePanelSquareCard(
          panels: squarePanels,
        ),
        NewKnowledgePanelTitleCard(
          title: 'Transformation des aliments',
          subtitle: novaPanel.titleElement?.subtitle ?? '',
          iconUrl: novaPanel.titleElement?.iconUrl,
        ),
      ],
    );
  }
}

class NewKnowledgePanelTitleCard extends StatelessWidget {
  const NewKnowledgePanelTitleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconUrl,
  });

  final String title;
  final String subtitle;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: SMALL_SPACE,
      ),
      decoration: BoxDecoration(
        color: lightTheme
            ? themeExtension.primaryMedium
            : themeExtension.primaryDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: VERY_SMALL_SPACE),
              Text(
                subtitle,
                style: TextStyle(
                  color: lightTheme
                      ? themeExtension.primarySemiDark
                      : themeExtension.primaryMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          if (iconUrl != null && iconUrl!.isNotEmpty)
            SvgPicture.network(
              iconUrl!,
              height: 42.0,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }
}
