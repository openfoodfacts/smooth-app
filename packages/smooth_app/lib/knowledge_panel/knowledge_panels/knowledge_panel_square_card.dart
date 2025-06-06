import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({
    required this.panels,
  }) : assert(panels.length == 4);

  final List<KnowledgePanel> panels;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            children: <Widget>[
              _buildPanel(context, panels[0]),
              const VerticalDivider(
                thickness: 1.0,
              ),
              _buildPanel(context, panels[1]),
            ],
          ),
        ),
        const Divider(
          thickness: 1.0,
        ),
        IntrinsicHeight(
          child: Row(
            children: <Widget>[
              _buildPanel(context, panels[2]),
              const VerticalDivider(
                thickness: 1.0,
              ),
              _buildPanel(context, panels[3]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context, KnowledgePanel panel) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    return Expanded(
      child: Container(
        height: 100.0,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Text(
                  panel.titleElement?.name ?? 'No name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Row(
              children: <Widget>[
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColor(panel.evaluation, themeExtension),
                  ),
                ),
                const SizedBox(width: MEDIUM_SPACE),
                Text(
                  panel.titleElement?.value ?? 'No evaluation',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color indicatorColor(
      Evaluation? evaluation, SmoothColorsThemeExtension themeExtension) {
    if (evaluation == null) {
      return Colors.grey;
    }
    switch (evaluation) {
      case Evaluation.GOOD:
        return themeExtension.success;
      case Evaluation.BAD:
        return themeExtension.error;
      case Evaluation.AVERAGE:
        return themeExtension.warning;
      default:
        return Colors.grey;
    }
  }
}
