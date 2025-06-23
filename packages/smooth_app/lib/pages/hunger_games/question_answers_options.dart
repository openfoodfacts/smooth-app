import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';

const Color _yesBackground = Colors.lightGreen;
const Color _noBackground = Colors.redAccent;
const Color _maybeBackground = QuestionCard.robotoffBackground;
const Color _yesNoTextColor = Colors.white;
const Color _maybeTextColor = Colors.black;

/// Display of the typical Yes / No / Maybe options for Robotoff
class QuestionAnswersOptions extends StatelessWidget {
  const QuestionAnswersOptions(
    this.question, {
    super.key,
    required this.onAnswer,
  });

  final RobotoffQuestion question;
  final Function(InsightAnnotation) onAnswer;

  @override
  Widget build(BuildContext context) {
    final double yesNoHeight = MediaQuery.sizeOf(context).width / (3 * 1.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: _buildAnswerButton(
            context,
            insightAnnotation: InsightAnnotation.MAYBE,
            backgroundColor: _maybeBackground,
            contentColor: _maybeTextColor,
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
    EdgeInsets padding = const EdgeInsets.all(VERY_SMALL_SPACE),
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    String buttonText;
    String hintText;
    IconData iconData;
    switch (insightAnnotation) {
      case InsightAnnotation.YES:
        buttonText = appLocalizations.yes;
        hintText = appLocalizations.question_yes_button_accessibility_value;
        iconData = Icons.check;
        break;
      case InsightAnnotation.NO:
        buttonText = appLocalizations.no;
        hintText = appLocalizations.question_no_button_accessibility_value;
        iconData = Icons.clear;
        break;
      case InsightAnnotation.MAYBE:
        buttonText = appLocalizations.skip;
        hintText = appLocalizations.question_skip_button_accessibility_value;
        iconData = Icons.question_mark;
    }

    return Semantics(
      value: buttonText,
      hint: hintText,
      excludeSemantics: true,
      button: true,
      child: Padding(
        padding: padding,
        child: TextButton.icon(
          onPressed: () => onAnswer(insightAnnotation),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
            ),
          ),
          icon: Icon(iconData, color: contentColor, size: 36),
          label: Text(
            buttonText,
            style: theme.textTheme.displayMedium!.apply(color: contentColor),
          ),
        ),
      ),
    );
  }
}
