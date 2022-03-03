import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
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
  late Future<bool> _isUserLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isUserLoggedInFuture = UserManagementHelper.credentialsInStorage();
  }

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
        backgroundColor: const Color(0xff4f4f4f),
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
      return _buildCongratsWidget(context);
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
                ProductTitleCard(widget.product, dense: true),
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
              style: Theme.of(context).textTheme.headline4,
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
    final double yesNoButtonWidth = MediaQuery.of(context).size.width / 3;
    final RobotoffQuestion question = questions[currentQuestionIndex];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: yesNoButtonWidth,
              height: yesNoButtonWidth / 1.25,
              child: _buildAnswerButton(
                insightId: question.insightId,
                insightAnnotation: InsightAnnotation.NO,
                backgroundColor: Colors.redAccent,
                contentColor: Colors.white,
                currentQuestionIndex: currentQuestionIndex,
              ),
            ),
            SizedBox(
              width: yesNoButtonWidth,
              height: yesNoButtonWidth / 1.25,
              child: _buildAnswerButton(
                insightId: question.insightId,
                insightAnnotation: InsightAnnotation.YES,
                backgroundColor: Colors.lightGreen,
                contentColor: Colors.white,
                currentQuestionIndex: currentQuestionIndex,
              ),
            ),
          ],
        ),
        AspectRatio(
          aspectRatio: 8,
          child: _buildAnswerButton(
            insightId: question.insightId,
            insightAnnotation: InsightAnnotation.MAYBE,
            backgroundColor: Colors.white,
            contentColor: Colors.grey,
            currentQuestionIndex: currentQuestionIndex,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required String? insightId,
    required InsightAnnotation insightAnnotation,
    required Color backgroundColor,
    required Color contentColor,
    required int currentQuestionIndex,
  }) {
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
    return GestureDetector(
      onTap: () async {
        try {
          await saveAnswer(
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
      child: Card(
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

  Widget _buildCongratsWidget(BuildContext context) {
    final TextStyle bodyTextStyle =
        Theme.of(context).textTheme.bodyText2!.apply(color: Colors.white);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.grade,
            color: Colors.white,
            size: 72,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
            child: Text(
              appLocalizations.thanks_for_contributing,
              style: bodyTextStyle,
            ),
          ),
          FutureBuilder<bool>(
              future: _isUserLoggedInFuture,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  final bool isUserLoggedIn = snapshot.data!;
                  if (isUserLoggedIn) {
                    // TODO(jasmeet): Show leaderboard button.
                    return EMPTY_WIDGET;
                  }
                  return Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          Navigator.pop<Widget>(context);
                          await Navigator.push<Widget>(
                            context,
                            MaterialPageRoute<Widget>(
                              builder: (BuildContext context) =>
                                  const LoginPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(ANGULAR_RADIUS),
                            color: Colors.grey,
                          ),
                          width: 150,
                          padding: const EdgeInsets.all(MEDIUM_SPACE),
                          child: Center(
                            child: Text(
                              appLocalizations.sign_in,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
                        child: Text(
                          appLocalizations.sign_in_text,
                          style: bodyTextStyle,
                        ),
                      ),
                    ],
                  );
                } else {
                  return EMPTY_WIDGET;
                }
              }),
        ],
      ),
    );
  }
}

Future<void> saveAnswer(
  BuildContext context, {
  required String? insightId,
  required InsightAnnotation insightAnnotation,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  await LoadingDialog.run<Status>(
    context: context,
    future: OpenFoodAPIClient.postInsightAnnotation(
      insightId,
      insightAnnotation,
      deviceId: OpenFoodAPIConfiguration.uuid,
    ),
    title: appLocalizations.saving_answer,
  );
}
