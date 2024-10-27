import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/query/product_questions_query.dart';

class ProductQuestionsWidget extends StatefulWidget {
  const ProductQuestionsWidget(
    this.product, {
    this.layout = ProductQuestionsLayout.button,
  });

  final Product product;
  final ProductQuestionsLayout layout;

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

    return switch (widget.layout) {
      ProductQuestionsLayout.button => _ProductQuestionButton(
          state: _state,
          openQuestionsCallback: _openQuestions,
        ),
      ProductQuestionsLayout.banner => _ProductQuestionBanner(
          state: _state,
          openQuestionsCallback: _openQuestions,
        ),
    };
  }

  Future<void> _openQuestions() async {
    _trackEvent(AnalyticsEvent.questionClicked);

    await openQuestionPage(
      context,
      product: widget.product,
      questions: (_state as _ProductQuestionsWithQuestions).questions.toList(
            growable: false,
          ),
      updateProductUponAnswers: _updateProductUponAnswers,
    );

    if (context.mounted) {
      return _reloadQuestions(silentCheck: true);
    }
  }

  Future<void> _reloadQuestions({
    bool silentCheck = false,
  }) async {
    if (!silentCheck) {
      setState(() => _state = const _ProductQuestionsLoading());
    }

    final List<RobotoffQuestion>? list = await _loadProductQuestions();

    if (!mounted) {
      return;
    }

    if (list?.isNotEmpty == true && !_annotationVoted) {
      setState(() => _state = _ProductQuestionsWithQuestions(list!));
      _trackEvent(AnalyticsEvent.questionVisible);
    } else {
      setState(() => _state = const _ProductQuestionsWithoutQuestions());
    }
  }

  void _trackEvent(AnalyticsEvent event) => AnalyticsHelper.trackEvent(
        event,
        eventValue: switch (widget.layout) {
          ProductQuestionsLayout.button => 0,
          ProductQuestionsLayout.banner => 1,
        },
      );

  Future<List<RobotoffQuestion>?> _loadProductQuestions() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();

    try {
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
    } catch (_) {
      return null;
    }
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

/// A naive implementation to have a half of the user base using a button and
/// the other half, the banner
ProductQuestionsLayout getUserQuestionsLayout(UserPreferences preferences) {
  return preferences.userGroup.isEven
      ? ProductQuestionsLayout.button
      : ProductQuestionsLayout.banner;
}

enum ProductQuestionsLayout {
  button,
  banner,
}

class _ProductQuestionButton extends StatelessWidget {
  const _ProductQuestionButton({
    required this.state,
    required this.openQuestionsCallback,
  });

  final _ProductQuestionsState state;
  final VoidCallback openQuestionsCallback;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: state is _ProductQuestionsWithoutQuestions
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

        if (state is _ProductQuestionsWithQuestions) {
          return Semantics(
            value: appLocalizations.tap_to_answer_hint,
            button: true,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: ANGULAR_BORDER_RADIUS,
              onTap: openQuestionsCallback,
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: ANGULAR_BORDER_RADIUS,
                ),
                padding: const EdgeInsetsDirectional.all(
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
                padding: const EdgeInsetsDirectional.all(
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
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const _ProductQuestionIcon(),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: '${appLocalizations.tap_to_answer}\n',
                    style:
                        Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                              color: isDarkMode ? Colors.black : WHITE_COLOR,
                              height: 1.5,
                            ),
                    children: <TextSpan>[
                      TextSpan(
                        text: appLocalizations.contribute_to_get_rewards,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyMedium!
                            .copyWith(
                              color: isDarkMode ? Colors.black : WHITE_COLOR,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductQuestionBanner extends StatelessWidget {
  const _ProductQuestionBanner({
    required this.state,
    required this.openQuestionsCallback,
  });

  final _ProductQuestionsState state;
  final VoidCallback openQuestionsCallback;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color contentColor = isDarkMode ? Colors.black : WHITE_COLOR;

    // We need to differentiate with / without a Shimmer, because
    // [Shimmer] doesn't support [Ink]
    final Color backgroundColor = Theme.of(context).colorScheme.primary;

    final Widget child;
    if (state is! _ProductQuestionsWithQuestions) {
      child = const BlockSemantics(
        blocking: true,
        child: EMPTY_WIDGET,
      );
    } else {
      child = Semantics(
        value: appLocalizations.tap_to_answer_hint,
        button: true,
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: openQuestionsCallback,
            child: Ink(
              width: double.infinity,
              color: backgroundColor,
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: SMALL_SPACE,
                horizontal: VERY_LARGE_SPACE,
              ).add(
                EdgeInsetsDirectional.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                ),
              ),
              child: Row(
                children: <Widget>[
                  const _ProductQuestionIcon(),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: '${appLocalizations.tap_to_answer}\n',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyLarge!
                            .copyWith(
                              color: contentColor,
                              height: 1.5,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: appLocalizations.contribute_to_get_rewards,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium!
                                .copyWith(
                                  color: contentColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_circle_right_outlined,
                    color: contentColor,
                    size: 20.0,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      duration: SmoothAnimationsDuration.long,
      opacity: state is _ProductQuestionsWithQuestions ? 1.0 : 0.0,
      child: child,
    );
  }
}

class _ProductQuestionIcon extends StatelessWidget {
  const _ProductQuestionIcon();

  @override
  Widget build(BuildContext context) {
    final double size =
        (DefaultTextStyle.of(context).style.fontSize ?? 15.0) * 1.5;

    return BlockSemantics(
      blocking: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          end: SMALL_SPACE,
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: SvgPicture.asset(
          'assets/icons/medal.svg',
          width: size,
          height: size,
        ),
      ),
    );
  }
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
    required super.child,
  });

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

typedef OnQuestionVisible = Function(double height);
