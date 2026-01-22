import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_evaluation_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_indicator.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_modal_sheet.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareItem extends StatelessWidget {
  const KnowledgePanelSquareItem({
    required this.panelId,
    required this.panel,
    super.key,
  });

  final KnowledgePanel panel;
  final String? panelId;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final String title = panel.titleElement?.name ?? '';
    final Color indicatorColor = panel.evaluation.indicatorColor(theme);

    final String value = _reformatValue(
      AppLocalizations.of(context),
      panel.titleElement?.valueString ??
          panel.titleElement?.value?.toString() ??
          '',
    );

    return Expanded(
      child: InkWell(
        onTap: panelId != null
            ? () {
                showKnowledgePanelSquareModalSheet(
                  context,
                  title: title,
                  value: value,
                  panelId: panelId!,
                  product: context.read<Product>(),
                  valueColor: indicatorColor,
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VERY_LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                spacing: SMALL_SPACE,
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 3.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  icons.Chevron.horizontalDirectional(
                    context,
                    size: 12.0,
                    color: theme.greyMedium,
                  ),
                ],
              ),
              const SizedBox(height: SMALL_SPACE),
              Expanded(
                child: Row(
                  spacing: MEDIUM_SPACE,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    KnowledgePanelIndicator(evaluation: panel.evaluation),
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                          color: indicatorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reformat a percentage value string
  String _reformatValue(AppLocalizations appLocalizations, String value) {
    final double? numValue = double.tryParse(value.split('%').first);
    if (numValue == null) {
      return value;
    }

    return appLocalizations.percent_value(
      NumberFormat('#.##', ProductQuery.getLocaleString()).format(numValue),
    );
  }
}
