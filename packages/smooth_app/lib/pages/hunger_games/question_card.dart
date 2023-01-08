import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Display of a Robotoff question text.
class QuestionCard extends StatelessWidget {
  const QuestionCard(
    this.question, {
    Key? key,
  }) : super(key: key);

  final RobotoffQuestion question;

  static const Color robotoffBackground = Color(0xFFFFEFB7);

  @override
  Widget build(BuildContext context) {
    final Future<Product> productFuture = OpenFoodAPIClient.getProduct(
      ProductQueryConfiguration(question.barcode!),
    ).then((ProductResult result) => result.product!);

    return FutureBuilder<Product>(
        future: productFuture,
        builder: (BuildContext context, AsyncSnapshot<Product> snapshot) {
          if (!snapshot.hasData) {
            return _buildQuestionShimmer();
          }
          return _buildQuestionText(context, question);
        });
  }

  Widget _buildQuestionText(BuildContext context, RobotoffQuestion question) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: SMALL_SPACE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: VERY_SMALL_SPACE),
            child: Text(
              question.question!,
              style: theme.textTheme.headline4!.apply(
                color: isDarkMode ? Colors.white : theme.cardTheme.color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: VERY_SMALL_SPACE),
            child: Text(
              question.value!,
              style: theme.textTheme.headline4?.apply(
                  color: isDarkMode ? Colors.white : theme.cardTheme.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionShimmer() => Shimmer.fromColors(
        baseColor: robotoffBackground,
        highlightColor: Colors.white,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          child: Container(
            height: LARGE_SPACE * 4,
          ),
        ),
      );
}
