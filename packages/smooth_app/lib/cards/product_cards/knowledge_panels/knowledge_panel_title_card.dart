import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

class KnowledgePanelTitleCard extends StatelessWidget {
  const KnowledgePanelTitleCard({
    required this.knowledgePanelTitleElement,
    this.evaluation,
  });

  final TitleElement knowledgePanelTitleElement;
  final Evaluation? evaluation;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Color? colorFromEvaluation;
    if (evaluation != null &&
        (knowledgePanelTitleElement.iconColorFromEvaluation ?? false)) {
      colorFromEvaluation = _getColorFromEvaluation(evaluation!);
    }
    if (colorFromEvaluation == null &&
        themeData.brightness == Brightness.dark) {
      colorFromEvaluation = Colors.white;
    }
    List<Widget> iconWidget;
    if (knowledgePanelTitleElement.iconUrl != null) {
      iconWidget = <Widget>[
        Expanded(
          flex: IconWidgetSizer.getIconFlex(),
          child: Center(
            child: AbstractCache.best(
              iconUrl: knowledgePanelTitleElement.iconUrl,
              width: 36,
              height: 36,
              color: colorFromEvaluation,
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: SMALL_SPACE)),
      ];
    } else {
      iconWidget = <Widget>[];
    }
    return Padding(
      padding: const EdgeInsets.only(top: SMALL_SPACE),
      child: Row(
        children: <Widget>[
          ...iconWidget,
          Expanded(
              flex: IconWidgetSizer.getRemainingWidgetFlex(),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  direction: Axis.vertical,
                  children: <Widget>[
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        knowledgePanelTitleElement.title,
                        style: TextStyle(color: colorFromEvaluation),
                      ),
                    ),
                    if (knowledgePanelTitleElement.subtitle != null)
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Text(knowledgePanelTitleElement.subtitle!),
                      ),
                  ],
                );
              })),
        ],
      ),
    );
  }

  Color? _getColorFromEvaluation(Evaluation evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return Colors.red;
      case Evaluation.NEUTRAL:
        return Colors.grey;
      case Evaluation.AVERAGE:
        return Colors.orange;
      case Evaluation.GOOD:
        return Colors.green;
      case Evaluation.UNKNOWN:
        return null;
    }
  }
}
