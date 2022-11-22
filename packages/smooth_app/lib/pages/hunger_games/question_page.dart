import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/hunger_games/congrats.dart';
import 'package:smooth_app/pages/hunger_games/question_answers_options.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_questions_query.dart';
import 'package:smooth_app/query/questions_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    this.product,
    this.questions,
    this.updateProductUponAnswers,
    this.insightTypes,
  });

  final List<InsightType>? insightTypes;
  final Product? product;
  final List<RobotoffQuestion>? questions;
  final Function()? updateProductUponAnswers;
  bool get shouldDisplayContinueButton => product == null;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin, TraceableClientMixin {
  final Map<String, InsightAnnotation> _anonymousAnnotationList =
      <String, InsightAnnotation>{};
  InsightAnnotation? _lastAnswer;

  late Future<List<RobotoffQuestion>> questions;
  int _currentQuestionIndex = 0;
  late LocalDatabase _localDatabase;

  @override
  void initState() {
    super.initState();

    _localDatabase = context.read<LocalDatabase>();
    final List<RobotoffQuestion>? widgetQuestions = widget.questions;

    if (widgetQuestions != null) {
      questions = Future<List<RobotoffQuestion>>.value(widgetQuestions);
    } else {
      questions = _getQuestions(widget.product);
    }
  }

  void _reloadQuestions() {
    setState(() {
      questions = _getQuestions(widget.product);
      _currentQuestionIndex = 0;
    });
  }

  @override
  String get traceTitle => 'robotoff_question_page';

  @override
  String get traceName => 'Opened robotoff_question_page';

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          final Function()? callback = widget.updateProductUponAnswers;
          if (_lastAnswer != null && callback != null) {
            await callback();
          }
          return true;
        },
        child: SmoothScaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(),
          body: _buildAnimationSwitcher(),
        ),
      );

  AnimatedSwitcher _buildAnimationSwitcher() => AnimatedSwitcher(
        duration: SmoothAnimationsDuration.medium,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Offset animationStartOffset = _getAnimationStartOffset();
          final Animation<Offset> inAnimation = Tween<Offset>(
            begin: animationStartOffset,
            end: Offset.zero,
          ).animate(animation);
          final Animation<Offset> outAnimation = Tween<Offset>(
            begin: animationStartOffset.scale(-1, -1),
            end: Offset.zero,
          ).animate(animation);

          if (child.key == ValueKey<int>(_currentQuestionIndex)) {
            // Animate in the new question card.
            return ClipRect(
              child: SlideTransition(
                position: inAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: child,
                ),
              ),
            );
          } else {
            // Animate out the old question card.
            return ClipRect(
              child: SlideTransition(
                position: outAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: child,
                ),
              ),
            );
          }
        },
        child: Container(
          key: ValueKey<int>(_currentQuestionIndex),
          child: FutureBuilder<List<RobotoffQuestion>>(
            future: questions,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<RobotoffQuestion>> snapshot,
            ) =>
                snapshot.hasData
                    ? _buildWidget(
                        context,
                        questions: snapshot.data!,
                        questionIndex: _currentQuestionIndex,
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ),
      );

  Offset _getAnimationStartOffset() {
    switch (_lastAnswer) {
      case InsightAnnotation.YES:
        // For [InsightAnnotation.YES]: Animation starts from left side and goes right.
        return const Offset(-1.0, 0);
      case InsightAnnotation.NO:
        // For [InsightAnnotation.NO]: Animation starts from right side and goes left.
        return const Offset(1.0, 0);
      case InsightAnnotation.MAYBE:
      case null:
        // For [InsightAnnotation.MAYBE]: Animation starts from bottom and goes up.
        return const Offset(0, 1);
    }
  }

  Widget _buildWidget(
    BuildContext context, {
    required List<RobotoffQuestion> questions,
    required int questionIndex,
  }) {
    if (questions.length == questionIndex) {
      return CongratsWidget(
        shouldDisplayContinueButton: widget.shouldDisplayContinueButton,
        anonymousAnnotationList: _anonymousAnnotationList,
        onContinue: _reloadQuestions,
      );
    }

    final RobotoffQuestion question = questions[questionIndex];
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        QuestionCard(
          question,
          initialProduct: widget.product,
        ),
        QuestionAnswersOptions(
          question,
          onAnswer: (InsightAnnotation answer) => _trySave(
            question,
            answer,
            appLocalizations,
          ),
        )
      ],
    );
  }

  Future<void> _trySave(
    RobotoffQuestion question,
    InsightAnnotation insightAnnotation,
    AppLocalizations appLocalizations,
  ) async {
    try {
      await _saveAnswer(
        barcode: question.barcode,
        insightId: question.insightId,
        insightAnnotation: insightAnnotation,
      );
    } catch (e) {
      await LoadingDialog.error(
        context: context,
        title: appLocalizations.error_occurred,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _lastAnswer = insightAnnotation;
      _currentQuestionIndex++;
    });
  }

  Future<void> _saveAnswer({
    required String? barcode,
    required String? insightId,
    required InsightAnnotation insightAnnotation,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (OpenFoodAPIConfiguration.globalUser == null && insightId != null) {
      _anonymousAnnotationList.putIfAbsent(insightId, () => insightAnnotation);
    }
    await LoadingDialog.run<Status>(
      context: context,
      title: appLocalizations.saving_answer,
      future: _saveAnswerQuery(
        insightId: insightId,
        insightAnnotation: insightAnnotation,
        barcode: barcode,
      ),
    );
    if (barcode != null && insightId != null) {
      if (!mounted) {
        return;
      }
      final RobotoffInsightHelper robotoffInsightHelper =
          RobotoffInsightHelper(_localDatabase);
      await robotoffInsightHelper.cacheInsightAnnotationVoted(
        barcode,
        insightId,
      );
    }
  }

  Future<List<RobotoffQuestion>> _getQuestions(Product? product) async =>
      product != null
          ? ProductQuestionsQuery(product.barcode!).getQuestions()
          : QuestionsQuery().getQuestions();

  /// Saves the Robotoff answer and refreshes the product locally if relevant.
  Future<Status> _saveAnswerQuery({
    required String? barcode,
    required String? insightId,
    required InsightAnnotation insightAnnotation,
  }) async {
    final Status status = await OpenFoodAPIClient.postInsightAnnotation(
      insightId,
      insightAnnotation,
      deviceId: OpenFoodAPIConfiguration.uuid,
      user: OpenFoodAPIConfiguration.globalUser,
    );
    // TODO(monsieurtanuki): optim - do not ask QuestionCard to constantly refresh the product if we deal with several times the same product
    if (widget.product != null) {
      // here we have a special interest in that product being up-to-date
      await ProductRefresher().silentFetchAndRefresh(
        barcode: widget.product!.barcode!,
        localDatabase: _localDatabase,
      );
    }
    return status;
  }
}
