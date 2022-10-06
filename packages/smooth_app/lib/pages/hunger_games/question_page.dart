import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/hunger_games/congrats.dart';
import 'package:smooth_app/query/robotoff_questions_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const Color _noBackground = Colors.redAccent;
const Color _yesBackground = Colors.lightGreen;
const Color _yesNoTextColor = Colors.white;

const List<InsightType> ALL_INSIGHTS = <InsightType>[
  InsightType.CATEGORY,
  InsightType.LABEL,
  InsightType.PRODUCT_WEIGHT,
  InsightType.PACKAGER_CODE,
  InsightType.BRAND,
];

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    this.product,
    this.questions,
    this.updateProductUponAnswers,
    this.insightTypes = ALL_INSIGHTS,
  });

  final List<InsightType> insightTypes;
  final Product? product;
  final List<RobotoffQuestion>? questions;
  final Function()? updateProductUponAnswers;

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

  @override
  void initState() {
    super.initState();

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
        anonymousAnnotationList: _anonymousAnnotationList,
        onContinue: _reloadQuestions,
      );
    }

    final RobotoffQuestion question = questions[questionIndex];

    return Column(
      children: <Widget>[
        _buildQuestionCard(
          context,
          question,
        ),
        _buildAnswerOptions(
          context,
          question,
        )
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    RobotoffQuestion question,
  ) {
    final Future<Product> productFuture = OpenFoodAPIClient.getProduct(
      ProductQueryConfiguration(question.barcode!),
    ).then((ProductResult result) => result.product!);

    final Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder<Product>(
        future: productFuture,
        builder: (BuildContext context, AsyncSnapshot<Product> snapshot) {
          if (!snapshot.hasData) {
            return _buildQuestionShimmer();
          }
          final Product product = snapshot.data!;
          return Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            child: Column(
              children: <Widget>[
                ProductImageCarousel(
                  product,
                  height: screenSize.height / 6,
                  onUpload: (_) {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: Column(
                    children: <Widget>[
                      ProductTitleCard(
                        product,
                        true,
                        dense: true,
                      ),
                    ],
                  ),
                ),
                _buildQuestionText(context, question),
              ],
            ),
          );
        });
  }

  Widget _buildQuestionText(BuildContext context, RobotoffQuestion question) {
    return Container(
      color: const Color(0xFFFFEFB7),
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsetsDirectional.only(bottom: SMALL_SPACE),
            child: Text(
              question.question!,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .apply(color: Colors.black),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(ANGULAR_RADIUS),
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: Text(
              question.value!,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .apply(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionShimmer() => Shimmer.fromColors(
        baseColor: const Color(0xFFFFEFB7),
        highlightColor: Colors.white,
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          child: Container(
            height: LARGE_SPACE * 10,
          ),
        ),
      );

  Widget _buildAnswerOptions(
    BuildContext context,
    RobotoffQuestion question,
  ) {
    final double yesNoHeight = MediaQuery.of(context).size.width / (3 * 1.25);

    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: yesNoHeight,
                  child: _buildAnswerButton(
                    question: question,
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
                    question: question,
                    insightAnnotation: InsightAnnotation.YES,
                    backgroundColor: _yesBackground,
                    contentColor: _yesNoTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildAnswerButton(
                question: question,
                insightAnnotation: InsightAnnotation.MAYBE,
                backgroundColor: const Color(0xFFFFEFB7),
                contentColor: Colors.black,
                textButton: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required RobotoffQuestion question,
    required InsightAnnotation insightAnnotation,
    required Color backgroundColor,
    required Color contentColor,
    bool textButton = false,
    EdgeInsets padding = const EdgeInsets.all(VERY_SMALL_SPACE),
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    String buttonText;
    IconData iconData;
    switch (insightAnnotation) {
      case InsightAnnotation.YES:
        buttonText = appLocalizations.yes;
        iconData = Icons.check;
        break;
      case InsightAnnotation.NO:
        buttonText = appLocalizations.no;
        iconData = Icons.clear;
        break;
      case InsightAnnotation.MAYBE:
        buttonText = appLocalizations.skip;
        iconData = Icons.question_mark;
    }
    final Icon buttonIcon = Icon(
      iconData,
      color: contentColor,
      size: 36,
    );
    final Text buttonLabel = Text(
      buttonText,
      style: Theme.of(context).textTheme.headline2!.apply(color: contentColor),
    );

    return Padding(
      padding: padding,
      child: TextButton.icon(
        onPressed: () => trySave(
          question,
          insightAnnotation,
          appLocalizations,
        ),
        style: textButton
            ? null
            : ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundColor),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: ROUNDED_BORDER_RADIUS,
                  ),
                ),
              ),
        icon: buttonIcon,
        label: buttonLabel,
      ),
    );
  }

  Future<void> trySave(
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
      // TODO(monsieurtanuki): remove that line when fixed in [off-dart #451](https://github.com/openfoodfacts/openfoodfacts-dart/pull/451)
      future: OpenFoodAPIClient.postInsightAnnotation(
        insightId,
        insightAnnotation,
        deviceId: OpenFoodAPIConfiguration.uuid,
        user: OpenFoodAPIConfiguration.globalUser,
      ),
    );
    if (barcode != null && insightId != null) {
      if (!mounted) {
        return;
      }
      final LocalDatabase localDatabase = context.read<LocalDatabase>();
      final RobotoffInsightHelper robotoffInsightHelper =
          RobotoffInsightHelper(localDatabase);
      await robotoffInsightHelper.cacheInsightAnnotationVoted(
        barcode,
        insightId,
      );
    }
  }

  Future<List<RobotoffQuestion>> _getQuestions(Product? product) async {
    final User user = OpenFoodAPIConfiguration.globalUser!;

    if (product != null) {
      final Set<RobotoffQuestion> questions =
          await RobotoffQuestionsQuery(product.barcode!)
              .getRobotoffQuestionsForProduct();

      return questions.toList();
    } else {
      final String lc = OpenFoodAPIConfiguration.globalLanguages![0].code;

      final RobotoffQuestionResult result =
          await OpenFoodAPIClient.getRandomRobotoffQuestion(
        lc,
        user,
        types: widget.insightTypes,
        count: 3,
      );

      return result.questions ?? <RobotoffQuestion>[];
    }
  }
}
