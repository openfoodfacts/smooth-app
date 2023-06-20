import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/query/product_questions_query.dart';

class ProductQuestionsWidget extends StatefulWidget {
  const ProductQuestionsWidget(this.product);

  final Product product;

  @override
  State<ProductQuestionsWidget> createState() => _ProductQuestionsWidgetState();
}

/// This Widget has three views possible:
/// - When loading: a [Shimmer] effect
/// - With questions: a Button to open the dedicated screen
/// - Without questions: the default [EMPTY_WIDGET]
class _ProductQuestionsWidgetState extends State<ProductQuestionsWidget>
    with AutomaticKeepAliveClientMixin {
  /// This Widget has three states possible:
  /// - Loading
  /// - With questions: questions available AND never answered
  /// - Without questions: when there is no question OR a generic error happened
  _ProductQuestionsState _state = const _ProductQuestionsLoading();

  bool _annotationVoted = false;
  bool _keepWidgetAlive = true;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      _reloadQuestions();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool shouldKeepWidgetAlive =
        KeepQuestionWidgetAlive.shouldKeepAlive(context);

    // Force the Widget to reload questions only when transitioning
    // from not kept alive (false) to keep alive (true)
    if (_keepWidgetAlive != shouldKeepWidgetAlive && shouldKeepWidgetAlive) {
      _reloadQuestions();
    }

    _keepWidgetAlive = shouldKeepWidgetAlive;
  }

  @override
  Widget build(BuildContext context) {
    // Mandatory to call with an [AutomaticKeepAliveClientMixin]
    super.build(context);

    return AnimatedCrossFade(
      crossFadeState: _state is _ProductQuestionsWithoutQuestions
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: SmoothAnimationsDuration.long,
      firstChild: EMPTY_WIDGET,
      secondChild: Builder(builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final Widget child = _buildContent(context, appLocalizations);

        // We need to differentiate with / without a Shimmer, because
        // [Shimmer] doesn't support [Ink]
        final Color backgroundColor = Theme.of(context).colorScheme.primary;

        if (_state is _ProductQuestionsWithQuestions) {
          return Semantics(
            value: appLocalizations.tap_to_answer_hint,
            button: true,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: ANGULAR_BORDER_RADIUS,
              onTap: () => openQuestionPage(
                context,
                product: widget.product,
                questions:
                    (_state as _ProductQuestionsWithQuestions).questions.toList(
                          growable: false,
                        ),
                updateProductUponAnswers: _updateProductUponAnswers,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: ANGULAR_BORDER_RADIUS,
                ),
                padding: const EdgeInsets.all(
                  SMALL_SPACE,
                ),
                child: child,
              ),
            ),
          );
        } else {
          return Semantics(
            value: appLocalizations.robotoff_questions_loading_hint,
            excludeSemantics: true,
            child: Shimmer.fromColors(
              baseColor: backgroundColor,
              highlightColor: WHITE_COLOR.withOpacity(0.5),
              period: SmoothAnimationsDuration.long * 2,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: ANGULAR_BORDER_RADIUS,
                ),
                padding: const EdgeInsets.all(
                  SMALL_SPACE,
                ),
                child: child,
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildContent(
      BuildContext context, AppLocalizations appLocalizations) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          // TODO(jasmeet): Use Material icon or SVG (after consulting UX).
          Text(
            '🏅 ${appLocalizations.tap_to_answer}',
            style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                  color: isDarkMode ? Colors.black : WHITE_COLOR,
                ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
            ),
            child: Text(
              appLocalizations.contribute_to_get_rewards,
              style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                    color: isDarkMode ? Colors.black : WHITE_COLOR,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadQuestions() async {
    setState(() => _state = const _ProductQuestionsLoading());
    final List<RobotoffQuestion>? list = await _loadProductQuestions();

    if (!mounted) {
      return;
    }

    if (list?.isNotEmpty == true && !_annotationVoted) {
      setState(() => _state = _ProductQuestionsWithQuestions(list!));
    } else {
      setState(() => _state = const _ProductQuestionsWithoutQuestions());
    }
  }

  Future<List<RobotoffQuestion>?> _loadProductQuestions() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<RobotoffQuestion> questions =
        await ProductQuestionsQuery(widget.product.barcode!)
            .getQuestions(localDatabase, 3);
    if (!mounted) {
      return null;
    }
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(localDatabase);
    _annotationVoted =
        await robotoffInsightHelper.areQuestionsAlreadyVoted(questions);
    return questions;
  }

  Future<void> _updateProductUponAnswers() async {
    // Reload the product questions, they might have been answered.
    // Or the backend may have new ones.
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<RobotoffQuestion> questions =
        await _loadProductQuestions() ?? <RobotoffQuestion>[];
    if (!mounted) {
      return;
    }
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(localDatabase);
    if (questions.isEmpty) {
      await robotoffInsightHelper
          .removeInsightAnnotationsSavedForProdcut(widget.product.barcode!);
    }
    _annotationVoted =
        await robotoffInsightHelper.areQuestionsAlreadyVoted(questions);
  }

  @override
  bool get wantKeepAlive => _keepWidgetAlive;
}

// Widget State
sealed class _ProductQuestionsState {
  const _ProductQuestionsState();
}

class _ProductQuestionsLoading extends _ProductQuestionsState {
  const _ProductQuestionsLoading();
}

class _ProductQuestionsWithQuestions extends _ProductQuestionsState {
  const _ProductQuestionsWithQuestions(this.questions);

  final List<RobotoffQuestion> questions;
}

class _ProductQuestionsWithoutQuestions extends _ProductQuestionsState {
  const _ProductQuestionsWithoutQuestions();
}

/// Indicates whether we should force a [ProductQuestionsWidget] Widget
/// to keep its state or not
class KeepQuestionWidgetAlive extends InheritedWidget {
  const KeepQuestionWidgetAlive({
    super.key,
    required this.keepWidgetAlive,
    required Widget child,
  }) : super(child: child);

  final bool keepWidgetAlive;

  static bool shouldKeepAlive(BuildContext context) {
    final KeepQuestionWidgetAlive? result =
        context.dependOnInheritedWidgetOfExactType<KeepQuestionWidgetAlive>();

    return result?.keepWidgetAlive ?? false;
  }

  @override
  bool updateShouldNotify(KeepQuestionWidgetAlive oldWidget) {
    return oldWidget.keepWidgetAlive != keepWidgetAlive;
  }
}
