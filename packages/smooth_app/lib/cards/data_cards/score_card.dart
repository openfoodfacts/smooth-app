import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
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
  VERY_GOOD;

  Color getBackgroundColor() {
    switch (this) {
      case CardEvaluation.UNKNOWN:
        return GREY_COLOR;
      case CardEvaluation.VERY_BAD:
        return RED_BACKGROUND_COLOR;
      case CardEvaluation.BAD:
        return ORANGE_BACKGROUND_COLOR;
      case CardEvaluation.NEUTRAL:
        return YELLOW_BACKGROUND_COLOR;
      case CardEvaluation.GOOD:
        return LIGHT_GREEN_BACKGROUND_COLOR;
      case CardEvaluation.VERY_GOOD:
        return DARK_GREEN_BACKGROUND_COLOR;
    }
  }

  Color getTextColor() {
    switch (this) {
      case CardEvaluation.UNKNOWN:
        return PRIMARY_GREY_COLOR;
      case CardEvaluation.VERY_BAD:
        return RED_COLOR;
      case CardEvaluation.BAD:
        return LIGHT_ORANGE_COLOR;
      case CardEvaluation.NEUTRAL:
        return DARK_YELLOW_COLOR;
      case CardEvaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case CardEvaluation.VERY_GOOD:
        return DARK_GREEN_COLOR;
    }
  }
}

class ScoreCard extends StatelessWidget {
  ScoreCard.attribute({
    required Attribute attribute,
    required this.isClickable,
    this.margin,
  })  : iconUrl = attribute.iconUrl,
        description = attribute.descriptionShort ?? attribute.description ?? '',
        cardEvaluation = getCardEvaluationFromAttribute(attribute);

  ScoreCard.titleElement({
    required TitleElement titleElement,
    required this.isClickable,
    this.margin,
  })  : iconUrl = titleElement.iconUrl,
        description = titleElement.title,
        cardEvaluation =
            getCardEvaluationFromKnowledgePanelTitleElement(titleElement);

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
        cardEvaluation.getBackgroundColor().withOpacity(opacity);
    final Color textColor = themeData.brightness == Brightness.dark
        ? Colors.white
        : cardEvaluation.getTextColor().withOpacity(opacity);
    final SvgIconChip? iconChip =
        iconUrl == null ? null : SvgIconChip(iconUrl!, height: iconHeight);

    return Semantics(
      value: _generateSemanticsValue(context),
      excludeSemantics: true,
      button: true,
      child: Padding(
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
                    style: themeData.textTheme.headlineMedium!
                        .apply(color: textColor),
                  ),
                ),
              ),
              if (isClickable) Icon(ConstantIcons.instance.getForwardIcon()),
            ],
          ),
        ),
      ),
    );
  }

  String _generateSemanticsValue(BuildContext context) {
    final String? iconLabel = SvgCache.getSemanticsLabel(context, iconUrl!);

    if (iconLabel == null) {
      return description;
    } else {
      return '$iconLabel: $description';
    }
  }
}
