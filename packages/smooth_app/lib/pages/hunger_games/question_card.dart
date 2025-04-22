import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/cards/product_cards/product_title_card.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/hunger_games/question_image_thumbnail.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Display of a Robotoff question text.
class QuestionCard extends StatelessWidget {
  const QuestionCard(
    this.question, {
    this.initialProduct,
    super.key,
  });

  final RobotoffQuestion question;
  final Product? initialProduct;

  static const Color robotoffBackground = Color(0xFFFFEFB7);

  @override
  Widget build(BuildContext context) {
    final Future<FetchedProduct> productFuture = _getProduct(
      question.barcode!,
      context.read<LocalDatabase>(),
    );

    return FutureBuilder<FetchedProduct>(
      future: productFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<FetchedProduct> snapshot,
      ) {
        Product? product;
        if (snapshot.connectionState == ConnectionState.done) {
          product = snapshot.data?.product;
          // TODO(monsieurtanuki): do something aggressive if product is null here and we don't have a fallback value - like an error widget
        }
        // fallback version
        product ??= initialProduct;
        if (product == null) {
          return _buildQuestionShimmer();
        }
        return Semantics(
          value: '${question.question} ${question.value}',
          readOnly: true,
          child: ExcludeSemantics(
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: ROUNDED_BORDER_RADIUS,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: question.imageUrl == null
                        ? EMPTY_WIDGET
                        : QuestionImageThumbnail(question),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SMALL_SPACE,
                      end: SMALL_SPACE,
                      top: SMALL_SPACE,
                      bottom: VERY_SMALL_SPACE,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionText(BuildContext context, RobotoffQuestion question) {
    return Container(
      color: robotoffBackground,
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsetsDirectional.only(bottom: SMALL_SPACE),
            child: Text(
              question.question!,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
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
                  .headlineMedium!
                  .apply(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<FetchedProduct> _getProduct(
    final String barcode,
    final LocalDatabase localDatabase,
  ) async {
    final Product? result = await DaoProduct(localDatabase).get(barcode);
    if (result != null) {
      return FetchedProduct.found(result);
    }
    return ProductRefresher().silentFetchAndRefresh(
      barcode: question.barcode!,
      localDatabase: localDatabase,
    );
  }

  Widget _buildQuestionShimmer() => Shimmer.fromColors(
        baseColor: robotoffBackground,
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
