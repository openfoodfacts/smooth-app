import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_hunger_games.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/hunger_games/congrats.dart';
import 'package:smooth_app/pages/hunger_games/question_answers_options.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';
import 'package:smooth_app/query/product_questions_query.dart';
import 'package:smooth_app/query/questions_query.dart';
import 'package:smooth_app/query/random_questions_query.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({
    this.product,
    this.questions,
  });

  final Product? product;
  final List<RobotoffQuestion>? questions;

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage>
    with SingleTickerProviderStateMixin, TraceableClientMixin {
  final AnonymousAnnotationList _anonymousAnnotationList =
      <String, InsightAnnotation>{};
  InsightAnnotation? _lastAnswer;

  static const int _numberQuestionsInit = 3;
  static const int _numberQuestionsNext = 10;

  late final QuestionsQuery _questionsQuery;
  late final LocalDatabase _localDatabase;

  CancelableOperation<List<RobotoffQuestion>>? _request;
  _RobotoffQuestionState _state = const _RobotoffQuestionLoadingState();
  int _currentQuestionIndex = 0;
  int _questionsAnswered = 0;

  @override
  void initState() {
    super.initState();

    _localDatabase = context.read<LocalDatabase>();
    _questionsQuery = widget.product != null
        ? ProductQuestionsQuery(widget.product!.barcode!)
        : RandomQuestionsQuery();

    _loadQuestions();
  }

  Future<void> _loadQuestions({
    Future<List<RobotoffQuestion>>? request,
  }) async {
    _updateState(const _RobotoffQuestionLoadingState());

    final List<RobotoffQuestion>? widgetQuestions = widget.questions;

    try {
      _request?.cancel();
      _request = CancelableOperation<List<RobotoffQuestion>>.fromFuture(
        request ??
            switch (widgetQuestions) {
              null => _questionsQuery.getQuestions(
                  _localDatabase,
                  _numberQuestionsInit,
                ),
              _ => Future<List<RobotoffQuestion>>.value(widgetQuestions)
            },
      );

      _updateState(_RobotoffQuestionSuccessState(await _request!.value));
    } on Exception catch (err) {
      _updateState(_RobotoffQuestionErrorState(err));
    } finally {
      _request = null;
    }
  }

  void _updateState(_RobotoffQuestionState state) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() => _state = state),
    );
  }

  void _loadNextQuestions() {
    try {
      if (mounted) {
        setState(() {
          _state = const _RobotoffQuestionLoadingState();
        });
      }
      unawaited(_loadQuestions(
        request: _questionsQuery.getQuestions(
          _localDatabase,
          _numberQuestionsNext,
        ),
      ));
      _currentQuestionIndex = 0;
    } catch (e) {
      _updateState(_RobotoffQuestionErrorState(Exception(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_QuestionsAnsweredNotifier>(
        create: (BuildContext context) => _QuestionsAnsweredNotifier(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Hunger Games'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(_questionsAnswered),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: SmoothAnimationsDuration.medium,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final Offset animationStartOffset =
                      _getAnimationStartOffset();
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
                      position:
                          child.key == ValueKey<int>(_currentQuestionIndex)
                              ? inAnimation
                              : outAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(SMALL_SPACE),
                        child: child,
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentQuestionIndex),
                  child: switch (_state) {
                    _RobotoffQuestionLoadingState _ =>
                      const _LoadingQuestionsView(),
                    _RobotoffQuestionSuccessState _ => _buildQuestionsWidget(),
                    _RobotoffQuestionErrorState _ =>
                      _ErrorLoadingView(onRetry: _loadQuestions),
                  },
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildQuestionsWidget() {
    final List<RobotoffQuestion> questions =
        (_state as _RobotoffQuestionSuccessState).questions;

    if (_currentQuestionIndex >= questions.length) {
      return _QuestionsSuccessView(
        onContinue: widget.product == null ? _loadNextQuestions : null,
        anonymousAnnotationList: _anonymousAnnotationList,
      );
    } else {
      final RobotoffQuestion question = questions[_currentQuestionIndex];
      return _QuestionView(
        question: question,
        initialProduct: widget.product,
        onAnswer: (InsightAnnotation answer) async {
          await _saveAnswer(question, answer);
          setState(() {
            _lastAnswer = answer;
            _currentQuestionIndex++;
            _questionsAnswered++;
          });
        },
      );
    }
  }

  Offset _getAnimationStartOffset() {
    switch (_lastAnswer) {
      case InsightAnnotation.YES:
        return const Offset(-1.0, 0);
      case InsightAnnotation.NO:
        return const Offset(1.0, 0);
      case InsightAnnotation.MAYBE:
      case null:
        return const Offset(0, 1);
    }
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
      context: context,
    );
  }

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  @override
  String get actionName => 'Opened robotoff_question_page';
}

sealed class _RobotoffQuestionState {
  const _RobotoffQuestionState();
}

class _RobotoffQuestionLoadingState extends _RobotoffQuestionState {
  const _RobotoffQuestionLoadingState();
}

class _RobotoffQuestionSuccessState extends _RobotoffQuestionState {
  const _RobotoffQuestionSuccessState(this.questions);

  final List<RobotoffQuestion> questions;
}

class _RobotoffQuestionErrorState extends _RobotoffQuestionState {
  const _RobotoffQuestionErrorState(this.error);

  final Exception error;
}

class _LoadingQuestionsView extends StatelessWidget {
  const _LoadingQuestionsView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return FutureBuilder<void>(
      future: Future<void>.delayed(const Duration(milliseconds: 500)),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.connectionState == ConnectionState.done ? 1 : 0,
          duration: SmoothAnimationsDuration.long,
          child: Center(
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: const TextStyle(),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: MergeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        appLocalizations.hunger_games_loading_line1,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 19.0),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      LinearProgressIndicator(
                        color: colorScheme.primary,
                      ),
                      SizedBox(height: screenHeight * 0.10),
                      Text(
                        appLocalizations.hunger_games_loading_line2,
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.bodyLarge?.copyWith(fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.initialProduct,
    required this.onAnswer,
  });

  final RobotoffQuestion question;
  final Product? initialProduct;
  final Function(InsightAnnotation) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: QuestionCard(
            question,
            initialProduct: initialProduct,
          ),
        ),
        QuestionAnswersOptions(
          question,
          onAnswer: onAnswer,
        ),
      ],
    );
  }
}

class _QuestionsSuccessView extends StatelessWidget {
  const _QuestionsSuccessView({
    required this.onContinue,
    required this.anonymousAnnotationList,
  });

  final VoidCallback? onContinue;
  final AnonymousAnnotationList anonymousAnnotationList;

  @override
  Widget build(BuildContext context) {
    return CongratsWidget(
      continueButtonLabel: onContinue != null
          ? AppLocalizations.of(context).robotoff_next_n_questions(
              _QuestionsPageState._numberQuestionsNext)
          : null,
      anonymousAnnotationList: anonymousAnnotationList,
      onContinue: onContinue,
      result: _QuestionsAnsweredNotifier.of(context).value,
    );
  }
}

class _ErrorLoadingView extends StatelessWidget {
  const _ErrorLoadingView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Center(
      child: DefaultTextStyle(
        textAlign: TextAlign.center,
        style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: colorScheme.onSurface,
            ) ??
            const TextStyle(),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                appLocalizations.hunger_games_error_label,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 20.0,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: VERY_LARGE_SPACE),
              SmoothLargeButtonWithIcon(
                text: appLocalizations.hunger_games_error_retry_button,
                leadingIcon: Icon(
                  Icons.refresh,
                  color: colorScheme.onPrimary,
                ),
                onPressed: onRetry,
                textStyle: textTheme.labelLarge?.copyWith(
                  fontSize: 18.0,
                  color: colorScheme.onPrimary,
                ),
                backgroundColor: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Holds the number of questions answered
class _QuestionsAnsweredNotifier extends ValueNotifier<int> {
  _QuestionsAnsweredNotifier() : super(0);

  void increment() {
    value++;
  }

  static _QuestionsAnsweredNotifier of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<_QuestionsAnsweredNotifier>(context, listen: listen);
}
