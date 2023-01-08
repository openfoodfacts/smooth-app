import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Insight.dart';
import 'package:openfoodfacts/model/RobotoffQuestion.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';

Color _yesBackground = Colors.grey.shade300;
Color _noBackground = Colors.grey.shade300;
const Color _maybeBackground = QuestionCard.robotoffBackground;
const Color _yesNoTextColor = Colors.lightGreen;
const Color _maybeTextColor = Colors.redAccent;

/// Display of the typical Yes / No / Maybe options for Robotoff
class QuestionAnswersOptions extends StatelessWidget {
  const QuestionAnswersOptions(
    this.question, {
    Key? key,
    required this.onAnswer,
  }) : super(key: key);

  final RobotoffQuestion question;
  final Function(InsightAnnotation) onAnswer;

  @override
  Widget build(BuildContext context) {
    final double yesNoHeight = MediaQuery.of(context).size.width / (6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.MAYBE,
              backgroundColor: _maybeBackground,
              contentColor: _maybeTextColor,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.YES,
              backgroundColor: _yesBackground,
              contentColor: _yesNoTextColor,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.NO,
              backgroundColor: _noBackground,
              contentColor: _yesNoTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
    BuildContext context, {
    required InsightAnnotation insightAnnotation,
    required Color backgroundColor,
    required Color contentColor,
    EdgeInsets padding = const EdgeInsets.all(SMALL_SPACE),
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    String buttonText;
    switch (insightAnnotation) {
      case InsightAnnotation.YES:
        buttonText = appLocalizations.yes;
        break;
      case InsightAnnotation.NO:
        buttonText = appLocalizations.no;
        break;
      case InsightAnnotation.MAYBE:
        buttonText = appLocalizations.skip;
    }

    return Padding(
      padding: padding,
      child: TextButton(
        onPressed: () => onAnswer(insightAnnotation),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
        ),
        child: Text(
          buttonText,
          style: theme.textTheme.headline3!.apply(color: contentColor),
        ),
      ),
    );
  }
}
