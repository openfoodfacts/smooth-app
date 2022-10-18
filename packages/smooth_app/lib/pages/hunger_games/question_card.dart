import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Display of a Robotoff question text.
class QuestionCard extends StatelessWidget {
  const QuestionCard(
    this.question, {
    Key? key,
  }) : super(key: key);

  final RobotoffQuestion question;

  @override
  Widget build(BuildContext context) {
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
}
