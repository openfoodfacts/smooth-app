import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
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
    final ColorScheme colorScheme = themeData.colorScheme;
    Color? colorFromEvaluation;
    Color? iconColorFromEvaluation;
    if (evaluation != null &&
        (knowledgePanelTitleElement.iconColorFromEvaluation ?? false)) {
      colorFromEvaluation = _getColorFromEvaluation(evaluation!);
      iconColorFromEvaluation = _getColorFromEvaluation(evaluation!);
    }
    if (evaluation != null &&
        _getColorFromEvaluation(evaluation!) == null &&
        themeData.brightness == Brightness.dark) {
      colorFromEvaluation = Colors.white;
      iconColorFromEvaluation = colorScheme.primary;
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
              color: iconColorFromEvaluation,
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
                        child: Text(knowledgePanelTitleElement.subtitle!)
                            .selectable(),
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
        return RED_COLOR;
      case Evaluation.NEUTRAL:
        return PRIMARY_GREY_COLOR;
      case Evaluation.AVERAGE:
        return LIGHT_ORANGE_COLOR;
      case Evaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case Evaluation.UNKNOWN:
        return null;
    }
  }
}
