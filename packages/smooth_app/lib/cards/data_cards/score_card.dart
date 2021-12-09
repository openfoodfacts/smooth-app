import 'package:flutter/material.dart';
import 'package:smooth_app/cards/data_cards/svg_icon_chip.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

enum CardEvaluation {
  UNKNOWN,
  VERY_BAD,
  BAD,
  NEUTRAL,
  GOOD,
  VERY_GOOD,
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    required this.iconUrl,
    required this.description,
    required this.cardEvaluation,
  });

  final String iconUrl;
  final String description;
  final CardEvaluation cardEvaluation;

  @override
  Widget build(BuildContext context) {
    final double iconHeight = IconWidgetSizer.getIconSizeFromContext(context);
    final ThemeData themeData = Theme.of(context);
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;
    final Color backgroundColor =
        getBackgroundColor(cardEvaluation).withOpacity(opacity);
    final Color textColor = themeData.brightness == Brightness.dark
        ? Colors.white
        : getTextColor(cardEvaluation).withOpacity(opacity);
    final SvgIconChip iconChip = SvgIconChip(iconUrl, height: iconHeight);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: iconChip,
            ),
            flex: 1,
          ),
          Expanded(
            child: Center(
              child: Text(
                description,
                style: themeData.textTheme.headline4!.apply(color: textColor),
              ),
            ),
            flex: 3,
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
