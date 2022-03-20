import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

Color getBackgroundColor(CardEvaluation evaluation) {
  switch (evaluation) {
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

Color getBackgroundColorFromAttribute(Attribute attribute) {
  return getBackgroundColor(getCardEvaluationFromAttribute(attribute));
}

Color getTextColor(CardEvaluation evaluation) {
  switch (evaluation) {
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

CardEvaluation getCardEvaluationFromAttribute(Attribute attribute) {
  switch (getAttributeEvaluation(attribute)) {
    case AttributeEvaluation.UNKNOWN:
      return CardEvaluation.UNKNOWN;
    case AttributeEvaluation.VERY_BAD:
      return CardEvaluation.VERY_BAD;
    case AttributeEvaluation.BAD:
      return CardEvaluation.BAD;
    case AttributeEvaluation.NEUTRAL:
      return CardEvaluation.NEUTRAL;
    case AttributeEvaluation.GOOD:
      return CardEvaluation.GOOD;
    case AttributeEvaluation.VERY_GOOD:
      return CardEvaluation.VERY_GOOD;
  }
}

CardEvaluation getCardEvaluationFromKnowledgePanelTitleElement(
    TitleElement titleElement) {
  switch (titleElement.grade) {
    case Grade.E:
      return CardEvaluation.VERY_BAD;
    case Grade.D:
      return CardEvaluation.BAD;
    case Grade.C:
      return CardEvaluation.NEUTRAL;
    case Grade.B:
      return CardEvaluation.GOOD;
    case Grade.A:
      return CardEvaluation.VERY_GOOD;
    case null:
    case Grade.UNKNOWN:
      return CardEvaluation.UNKNOWN;
  }
}
