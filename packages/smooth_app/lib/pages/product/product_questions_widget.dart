import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/query/product_questions_query.dart';

class ProductQuestionsWidget extends StatefulWidget {
  const ProductQuestionsWidget(this.product);

  final Product product;

  @override
  State<ProductQuestionsWidget> createState() => _ProductQuestionsWidgetState();
}

class _ProductQuestionsWidgetState extends State<ProductQuestionsWidget> {
  bool _annotationVoted = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<RobotoffQuestion>?>(
      future: _loadProductQuestions(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<RobotoffQuestion>?> snapshot,
      ) {
        final List<RobotoffQuestion> questions =
            snapshot.data ?? <RobotoffQuestion>[];

        if (questions.isNotEmpty && !_annotationVoted) {
          return InkWell(
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => QuestionPage(
                    product: widget.product,
                    questions: questions.toList(),
                    updateProductUponAnswers: _updateProductUponAnswers,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
            child: SmoothCard.angular(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.primary,
              elevation: 0,
              padding: const EdgeInsets.all(
                SMALL_SPACE,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    // TODO(jasmeet): Use Material icon or SVG (after consulting UX).
                    Text(
                      '🏅 ${appLocalizations.tap_to_answer}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyLarge!
                          .copyWith(
                            color: isDarkMode ? Colors.black : WHITE_COLOR,
                          ),
                    ),
                    Container(
                      padding:
                          const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                      child: Text(
                        appLocalizations.contribute_to_get_rewards,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyText2!
                            .copyWith(
                              color: isDarkMode ? Colors.black : WHITE_COLOR,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return EMPTY_WIDGET;
      },
    );
  }

  Future<List<RobotoffQuestion>?> _loadProductQuestions() async {
    final List<RobotoffQuestion> questions =
        await ProductQuestionsQuery(widget.product.barcode!).getQuestions();
    if (!mounted) {
      return null;
    }
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(context.read<LocalDatabase>());
    _annotationVoted =
        await robotoffInsightHelper.areQuestionsAlreadyVoted(questions);
    return questions;
  }

  Future<void> _updateProductUponAnswers() async {
    // Reload the product questions, they might have been answered.
    // Or the backend may have new ones.
    final List<RobotoffQuestion> questions =
        await _loadProductQuestions() ?? <RobotoffQuestion>[];
    if (!mounted) {
      return;
    }
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(context.read<LocalDatabase>());
    if (questions.isEmpty) {
      await robotoffInsightHelper
          .removeInsightAnnotationsSavedForProdcut(widget.product.barcode!);
    }
    _annotationVoted =
        await robotoffInsightHelper.areQuestionsAlreadyVoted(questions);
  }
}
