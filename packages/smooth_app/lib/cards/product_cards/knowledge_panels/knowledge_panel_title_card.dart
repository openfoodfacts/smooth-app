import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

class KnowledgePanelTitleCard extends StatelessWidget {
  const KnowledgePanelTitleCard({
    required this.knowledgePanelTitleElement,
    this.evaluation,
  });

  final TitleElement knowledgePanelTitleElement;
  final Evaluation? evaluation;

  @override
  Widget build(BuildContext context) {
    Color? colorFromEvaluation;
    if (evaluation != null &&
        (knowledgePanelTitleElement.iconColorFromEvaluation ?? false)) {
      colorFromEvaluation = _getColorFromEvaluation(evaluation!);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 36,
            width: 36,
            child: Center(
                child: SvgCache(
              knowledgePanelTitleElement.iconUrl,
              color: colorFromEvaluation,
              width: 36,
              height: 36,
            )),
          ),
          const Padding(padding: EdgeInsets.only(left: 16.0)),
          Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Text(
                knowledgePanelTitleElement.title,
                style: TextStyle(color: colorFromEvaluation),
              ),
              if (knowledgePanelTitleElement.subtitle != null)
                SizedBox(
                  // TODO(jasmeet): Don't hard code the width, somehow obtain this dynamically.
                  width: 300,
                  child: Text(
                    knowledgePanelTitleElement.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color? _getColorFromEvaluation(Evaluation evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return Colors.red;
      case Evaluation.NEUTRAL:
        return Colors.yellow;
      case Evaluation.GOOD:
        return Colors.green;
      case Evaluation.UNKNOWN:
    }
  }
}
