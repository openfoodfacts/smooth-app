import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class KnowledgePanelTitleCard extends StatelessWidget {
  const KnowledgePanelTitleCard({
    required this.knowledgePanelTitleElement,
    required this.isClickable,
    this.evaluation,
    this.temporaryNewDisplay = false,
  });

  final TitleElement knowledgePanelTitleElement;
  final Evaluation? evaluation;
  final bool isClickable;
  // it's a test around https://github.com/openfoodfacts/smooth-app/issues/2530
  final bool temporaryNewDisplay;

  @override
  Widget build(BuildContext context) {
    Color? colorFromEvaluation;
    String? emoji;
    if (temporaryNewDisplay) {
      emoji = _getEmojiEvaluation(evaluation);
    } else {
      final ThemeData themeData = Theme.of(context);
      if (knowledgePanelTitleElement.iconColorFromEvaluation ?? false) {
        if (themeData.brightness == Brightness.dark) {
          colorFromEvaluation = _getColorFromEvaluationDarkMode(evaluation);
        } else {
          colorFromEvaluation = _getColorFromEvaluation(evaluation);
        }
      }
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
        if (emoji != null)
          Padding(
            padding: const EdgeInsets.only(right: SMALL_SPACE),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: DEFAULT_ICON_SIZE),
            ),
          ),
      ];
    } else {
      iconWidget = <Widget>[];
    }
    return Padding(
      padding: const EdgeInsets.only(
        top: VERY_SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
      ),
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
              },
            ),
          ),
          if (isClickable)
            if (isClickable) Icon(ConstantIcons.instance.getForwardIcon()),
        ],
      ),
    );
  }

  Color _getColorFromEvaluation(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return RED_COLOR;
      case Evaluation.AVERAGE:
        return LIGHT_ORANGE_COLOR;
      case Evaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return PRIMARY_GREY_COLOR;
    }
  }

  Color _getColorFromEvaluationDarkMode(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return RED_COLOR;
      case Evaluation.AVERAGE:
        return LIGHT_ORANGE_COLOR;
      case Evaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return LIGHT_GREY_COLOR;
    }
  }

  String? _getEmojiEvaluation(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return '🌧️';
      case Evaluation.AVERAGE:
        return '☁️';
      case Evaluation.GOOD:
        return '☀️';
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return null;
    }
  }
}
