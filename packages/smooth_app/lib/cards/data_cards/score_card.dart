import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

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
    required this.description,
    required this.cardEvaluation,
    required this.isClickable,
    this.iconUrl,
    this.margin,
  });

  final String? iconUrl;
  final String description;
  final CardEvaluation cardEvaluation;
  final bool isClickable;
  final EdgeInsetsGeometry? margin;

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
    final SvgIconChip? iconChip =
        iconUrl == null ? null : SvgIconChip(iconUrl!, height: iconHeight);

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: Ink(
        padding: const EdgeInsets.all(SMALL_SPACE),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: ANGULAR_BORDER_RADIUS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (iconChip != null)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
                  child: iconChip,
                ),
              ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  description,
                  style: themeData.textTheme.headline4!.apply(color: textColor),
                ),
              ),
            ),
            if (isClickable) Icon(ConstantIcons.instance.getForwardIcon()),
          ],
        ),
      ),
    );
  }
}
