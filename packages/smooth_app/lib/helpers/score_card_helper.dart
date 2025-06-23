import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

CardEvaluation getCardEvaluationFromAttribute(Attribute attribute) {
  return getAttributeEvaluation(attribute).getCardEvaluation();
}

extension GradeExtension on Grade? {
  CardEvaluation getCardEvaluation() {
    switch (this) {
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
}

CardEvaluation getCardEvaluationFromKnowledgePanelTitleElement(
  TitleElement titleElement,
) => titleElement.grade.getCardEvaluation();
