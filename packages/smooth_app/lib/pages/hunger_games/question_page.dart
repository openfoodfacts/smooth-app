import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_hunger_games.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/hunger_games/congrats.dart';
import 'package:smooth_app/pages/hunger_games/question_answers_options.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';
import 'package:smooth_app/query/product_questions_query.dart';
import 'package:smooth_app/query/questions_query.dart';
import 'package:smooth_app/query/random_questions_query.dart';

Future<void> openQuestionPage(
  BuildContext context, {
  Product? product,
  List<RobotoffQuestion>? questions,
  Function()? updateProductUponAnswers,
}) =>
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      pageBuilder: (_, __, ___) => EMPTY_WIDGET,
      transitionBuilder: (
        BuildContext context,
        Animation<double> a1,
        Animation<double> a2,
        Widget child,
      ) {
        return SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  excludeFromSemantics: true,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                    opacity: a1.value,
                    child: SafeArea(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                        child: _QuestionPage(
                          product: product,
                          questions: questions,
                          updateProductUponAnswers: updateProductUponAnswers,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                top: 0.0,
                start: SMALL_SPACE,
                child: Opacity(
                  opacity: a1.value,
                  child: const _CloseButton(),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );

class _QuestionPage extends StatefulWidget {
  const _QuestionPage({
    this.product,
    this.questions,
    this.updateProductUponAnswers,
  });

  final Product? product;
  final List<RobotoffQuestion>? questions;
  final Function()? updateProductUponAnswers;

  bool get shouldDisplayContinueButton => product == null;

  @override
  State<_QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<_QuestionPage>
    with SingleTickerProviderStateMixin, TraceableClientMixin {
  final Map<String, InsightAnnotation> _anonymousAnnotationList =
      <String, InsightAnnotation>{};
  InsightAnnotation? _lastAnswer;

  static const int _numberQuestionsInit = 3;
  static const int _numberQuestionsNext = 10;

  late Future<List<RobotoffQuestion>> _questions;
  late final QuestionsQuery _questionsQuery;
  late final LocalDatabase _localDatabase;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();

    _localDatabase = context.read<LocalDatabase>();
    _questionsQuery = widget.product != null
        ? ProductQuestionsQuery(widget.product!.barcode!)
        : RandomQuestionsQuery();

    final List<RobotoffQuestion>? widgetQuestions = widget.questions;

    if (widgetQuestions != null) {
      _questions = Future<List<RobotoffQuestion>>.value(widgetQuestions);
    } else {
      _questions = _questionsQuery.getQuestions(
        _localDatabase,
        _numberQuestionsInit,
      );
    }
  }

  void _reloadQuestions() {
    setState(() {
      _questions = _questionsQuery.getQuestions(
        _localDatabase,
        _numberQuestionsNext,
      );
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
        child: Center(child: _buildAnimationSwitcher()),
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

          return ClipRect(
            child: SlideTransition(
              position: child.key == ValueKey<int>(_currentQuestionIndex)
                  ? // Animate in the new question card.
                  inAnimation
                  // Animate out the old question card.
                  : outAnimation,
              child: Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentQuestionIndex),
          child: FutureBuilder<List<RobotoffQuestion>>(
            future: _questions,
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
        continueButtonLabel: !widget.shouldDisplayContinueButton
            ? null
            : AppLocalizations.of(context).robotoff_next_n_questions(
                _numberQuestionsNext,
              ),
        anonymousAnnotationList: _anonymousAnnotationList,
        onContinue: _reloadQuestions,
      );
    }

    final RobotoffQuestion question = questions[questionIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        QuestionCard(
          question,
          initialProduct: widget.product,
        ),
        QuestionAnswersOptions(
          question,
          onAnswer: (InsightAnnotation answer) async {
            await _saveAnswer(question, answer);
            setState(() {
              _lastAnswer = answer;
              _currentQuestionIndex++;
            });
          },
        ),
      ],
    );
  }

  Future<void> _saveAnswer(
    final RobotoffQuestion question,
    final InsightAnnotation insightAnnotation,
  ) async {
    final String? barcode = question.barcode;
    final String? insightId = question.insightId;
    if (barcode == null || insightId == null) {
      return;
    }
    if (OpenFoodAPIConfiguration.globalUser == null) {
      _anonymousAnnotationList.putIfAbsent(insightId, () => insightAnnotation);
    }
    await BackgroundTaskHungerGames.addTask(
      barcode: barcode,
      insightId: insightId,
      insightAnnotation: insightAnnotation,
      widget: this,
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    final String tooltip = MaterialLocalizations.of(context).closeButtonTooltip;

    return Semantics(
      value: tooltip,
      button: true,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.button,
        shape: const CircleBorder(),
        color: Theme.of(context).primaryColor,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.maybePop(context),
          child: Tooltip(
            message: tooltip,
            child: Container(
              width: kToolbarHeight,
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
