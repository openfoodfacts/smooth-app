import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Display of the typical Yes / No / Maybe options for Robotoff
class ProductQuestionAnswersOptions extends StatelessWidget {
  const ProductQuestionAnswersOptions(
    this.question, {
    Key? key,
    required this.onAnswer,
  }) : super(key: key);

  final RobotoffQuestion question;
  final Function(InsightAnnotation) onAnswer;

  @override
  Widget build(BuildContext context) {
    const Color yesBackground = Colors.green;
    const Color noBackground = Colors.red;
    const Color maybeBackground = Colors.white;
    const Color yesNoTextColor = Colors.white;
    final Color maybeTextColor = Colors.grey.shade700;

    final double yesNoHeight = MediaQuery.of(context).size.width / (6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.NO,
              backgroundColor: noBackground,
              contentColor: yesNoTextColor,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.MAYBE,
              backgroundColor: maybeBackground,
              contentColor: maybeTextColor,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: yesNoHeight,
            child: _buildAnswerButton(
              context,
              insightAnnotation: InsightAnnotation.YES,
              backgroundColor: yesBackground,
              contentColor: yesNoTextColor,
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
          style: theme.textTheme.displaySmall!.apply(color: contentColor),
        ),
      ),
    );
  }
}
