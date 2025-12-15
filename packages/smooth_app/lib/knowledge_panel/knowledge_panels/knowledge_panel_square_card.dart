import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({
    required this.panels,
    required this.product,
    this.square = true,
  });

  final List<KnowledgePanel> panels;
  final Product product;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: square
          ? <Widget>[
              ...List<Widget>.generate((panels.length + 1) ~/ 2, (int index) {
                final int firstIndex = index * 2;
                final int secondIndex = firstIndex + 1;
                return Column(
                  children: <Widget>[
                    if (index > 0) const Divider(thickness: 1.0),
                    IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          _buildPanel(
                            context,
                            panels[firstIndex],
                            themeExtension,
                          ),
                          const VerticalDivider(thickness: 1.0),
                          if (secondIndex < panels.length)
                            _buildPanel(
                              context,
                              panels[secondIndex],
                              themeExtension,
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ]
          : <Widget>[
              const Divider(),
              ...ListTile.divideTiles(
                context: context,
                tiles: panels.map(
                  (KnowledgePanel panel) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: MEDIUM_SPACE,
                      vertical: VERY_SMALL_SPACE,
                    ),
                    leading: _buildIndicator(panel.evaluation, themeExtension),
                    title: _buildTitle(
                      context,
                      panel.titleElement?.title ?? '',
                    ),
                    trailing: Icon(
                      ConstantIcons.forwardIcon,
                      color: themeExtension.primaryTone,
                      size: 16.0,
                    ),
                    visualDensity: VisualDensity.compact,
                    dense: true,
                  ),
                ),
              ),
              const Divider(),
            ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    KnowledgePanel panel,
    SmoothColorsThemeExtension themeExtension,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VERY_LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              spacing: SMALL_SPACE,
              children: <Widget>[
                Flexible(
                  child: Text(
                    panel.titleElement?.title ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  ConstantIcons.forwardIcon,
                  color: themeExtension.primaryTone,
                  size: 16.0,
                ),
              ],
            ),
            const SizedBox(height: SMALL_SPACE),
            Row(
              children: <Widget>[
                _buildIndicator(panel.evaluation, themeExtension),
                const SizedBox(width: MEDIUM_SPACE),
                Text(
                  panel.titleElement?.valueString ??
                      (panel.titleElement?.value != null
                          ? '${panel.titleElement?.value}'
                          : ''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: indicatorColor(panel.evaluation, themeExtension),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(
    Evaluation? evaluation,
    SmoothColorsThemeExtension themeExtension,
  ) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: indicatorColor(evaluation, themeExtension),
      ),
    );
  }

  Color indicatorColor(
    Evaluation? evaluation,
    SmoothColorsThemeExtension themeExtension,
  ) {
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

  Widget _buildTitle(BuildContext context, String title) {
    final RegExp parenthesesPattern = RegExp(r'\s*\([^)]+\)\s*$');
    final Match? match = parenthesesPattern.firstMatch(title);

    if (match != null) {
      final String mainText = title.substring(0, match.start).trim();
      final String parenthesesText = match.group(0)!.trim();

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final TextStyle textStyle = DefaultTextStyle.of(context).style;
          final TextPainter textPainter = TextPainter(
            text: TextSpan(text: mainText, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: constraints.maxWidth);

          if (!textPainter.didExceedMaxLines) {
            return RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(text: mainText),
                  TextSpan(text: '\n$parenthesesText'),
                ],
              ),
            );
          } else {
            return Text(title);
          }
        },
      );
    }

    return Text(title);
  }
}
