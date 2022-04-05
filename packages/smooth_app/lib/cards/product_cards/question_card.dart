import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    required this.product,
    required this.questions,
    required this.updateProductUponAnswers,
  });

  final Product product;
  final List<RobotoffQuestion> questions;
  final Function() updateProductUponAnswers;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  InsightAnnotation? _lastAnswer;

  static const Color _noBackground = Colors.redAccent;
  static const Color _yesBackground = Colors.lightGreen;
  static const Color _yesNoTextColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastAnswer != null) {
          await widget.updateProductUponAnswers();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(),
        body: _buildAnimationSwitcher(),
      ),
    );
  }

  AnimatedSwitcher _buildAnimationSwitcher() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
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
                padding: const EdgeInsets.all(8.0),
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
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ),
          );
        }
      },
      child: Container(
        key: ValueKey<int>(_currentQuestionIndex),
        child: _buildWidget(context, _currentQuestionIndex),
      ),
    );
  }

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

  Widget _buildWidget(BuildContext context, int currentQuestionIndex) {
    final List<RobotoffQuestion> questions = widget.questions;
    if (questions.length == currentQuestionIndex) {
      return const CongratsWidget();
    }
    return Column(
      children: <Widget>[
        _buildQuestionCard(
          context,
          widget.product,
          questions[currentQuestionIndex],
        ),
        _buildAnswerOptions(
          context,
          questions,
          currentQuestionIndex: currentQuestionIndex,
        )
      ],
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, Product product, RobotoffQuestion question) {
    final Size screenSize = MediaQuery.of(context).size;
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Column(
        children: <Widget>[
          ProductImageCarousel(
            widget.product,
            height: screenSize.height / 6,
            onUpload: (_) {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
            child: Column(
              children: <Widget>[
                ProductTitleCard(
                  widget.product,
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
  }

  Widget _buildQuestionText(BuildContext context, RobotoffQuestion question) {
    return Container(
      color: const Color(0xFFFFEFB7),
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: SMALL_SPACE),
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

  Widget _buildAnswerOptions(
      BuildContext context, List<RobotoffQuestion> questions,
      {required int currentQuestionIndex}) {
    final double yesNoHeight = MediaQuery.of(context).size.width / (3 * 1.25);
    final RobotoffQuestion question = questions[currentQuestionIndex];

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: yesNoHeight,
                child: _buildAnswerButton(
                  insightId: question.insightId,
                  insightAnnotation: InsightAnnotation.NO,
                  backgroundColor: _noBackground,
                  contentColor: _yesNoTextColor,
                  currentQuestionIndex: currentQuestionIndex,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: yesNoHeight,
                child: _buildAnswerButton(
                  insightId: question.insightId,
                  insightAnnotation: InsightAnnotation.YES,
                  backgroundColor: _yesBackground,
                  contentColor: _yesNoTextColor,
                  currentQuestionIndex: currentQuestionIndex,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildAnswerButton(
                insightId: question.insightId,
                insightAnnotation: InsightAnnotation.MAYBE,
                backgroundColor: const Color(0xFFFFEFB7),
                contentColor: Colors.black,
                currentQuestionIndex: currentQuestionIndex,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
      {required String? insightId,
      required InsightAnnotation insightAnnotation,
      required Color backgroundColor,
      required Color contentColor,
      required int currentQuestionIndex,
      EdgeInsets padding = const EdgeInsets.all(4)}) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    String buttonText;
    IconData? icon;
    switch (insightAnnotation) {
      case InsightAnnotation.YES:
        buttonText = appLocalizations.yes;
        icon = Icons.check;
        break;
      case InsightAnnotation.NO:
        buttonText = appLocalizations.no;
        icon = Icons.clear;
        break;
      case InsightAnnotation.MAYBE:
        buttonText = appLocalizations.skip;
    }
    return Padding(
      padding: padding,
      child: MaterialButton(
        onPressed: () async {
          try {
            await _saveAnswer(
              context,
              insightId: insightId,
              insightAnnotation: insightAnnotation,
            );
          } catch (e) {
            await LoadingDialog.error(
              context: context,
              title: appLocalizations.error_occurred,
            );
            Navigator.of(context).pop();
            return;
          }
          setState(() {
            _lastAnswer = insightAnnotation;
            _currentQuestionIndex++;
          });
        },
        elevation: 4,
        color: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: ROUNDED_BORDER_RADIUS,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 36,
              ),
            Text(
              buttonText,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .apply(color: contentColor),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _saveAnswer(
  BuildContext context, {
  required String? insightId,
  required InsightAnnotation insightAnnotation,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  await LoadingDialog.run<Status>(
    context: context,
    title: appLocalizations.saving_answer,
    future: OpenFoodAPIClient.postInsightAnnotation(
      insightId,
      insightAnnotation,
      deviceId: OpenFoodAPIConfiguration.uuid,
    ),
  );
}

class CongratsWidget extends StatelessWidget {
  const CongratsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserManagementProvider userManagementProvider =
        context.watch<UserManagementProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.grade,
            color: Colors.amber,
            size: 100,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
            child: Text(
              appLocalizations.thanks_for_contributing,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          FutureBuilder<bool>(
              future: userManagementProvider.credentialsInStorage(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  final bool isUserLoggedIn = snapshot.data!;
                  if (isUserLoggedIn) {
                    // TODO(jasmeet): Show leaderboard button.
                    return EMPTY_WIDGET;
                  }
                  return Column(
                    children: <Widget>[
                      SmoothActionButton(
                        text: appLocalizations.sign_in,
                        onPressed: () async {
                          Navigator.pop<Widget>(context);
                          await Navigator.push<Widget>(
                            context,
                            MaterialPageRoute<Widget>(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
                        child: Text(
                          appLocalizations.sign_in_text,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                } else {
                  return EMPTY_WIDGET;
                }
              }),
          TextButton(
            child: Text(appLocalizations.close),
            onPressed: () => Navigator.pop<Widget>(context),
          ),
        ],
      ),
    );
  }
}
