import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

Color getBackgroundColor(CardEvaluation evaluation) {
  switch (evaluation) {
    case CardEvaluation.UNKNOWN:
      return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
    case CardEvaluation.VERY_BAD:
      return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
    case CardEvaluation.BAD:
      return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
    case CardEvaluation.NEUTRAL:
      return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
    case CardEvaluation.GOOD:
      return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
    case CardEvaluation.VERY_GOOD:
      return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
  }
}

Color getBackgroundColorFromAttribute(Attribute attribute) {
  return getBackgroundColor(getCardEvaluationFromAttribute(attribute));
}

Color getTextColor(CardEvaluation evaluation) {
  switch (evaluation) {
    case CardEvaluation.UNKNOWN:
      return const Color.fromARGB(1, 75, 75, 75);
    case CardEvaluation.VERY_BAD:
      return const Color.fromARGB(1, 235, 87, 87);
    case CardEvaluation.BAD:
      return const Color.fromARGB(1, 242, 153, 74);
    case CardEvaluation.NEUTRAL:
      return const Color.fromARGB(255, 149, 116, 0);
    case CardEvaluation.GOOD:
      return const Color.fromARGB(1, 133, 187, 47);
    case CardEvaluation.VERY_GOOD:
      return const Color.fromARGB(1, 3, 129, 65);
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
