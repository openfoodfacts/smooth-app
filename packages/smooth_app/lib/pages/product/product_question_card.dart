import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Display of a Robotoff question text.
class ProductQuestionCard extends StatelessWidget {
  const ProductQuestionCard(
    this.question, {
    Key? key,
  }) : super(key: key);

  final RobotoffQuestion question;

  static const Color robotoffBackground = Color(0xFFFFEFB7);

  @override
  Widget build(BuildContext context) {
    final Future<Product?> productFuture =
        ProductRefresher().silentFetchAndRefresh(
      barcode: question.barcode!,
      localDatabase: context.read<LocalDatabase>(),
    );

    return FutureBuilder<Product?>(
        future: productFuture,
        builder: (BuildContext context, AsyncSnapshot<Product?> snapshot) {
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
      padding: const EdgeInsetsDirectional.only(start: SMALL_SPACE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: VERY_SMALL_SPACE),
            child: Text(
              question.question!,
              style: theme.textTheme.headlineMedium!.apply(
                color: isDarkMode ? Colors.white : theme.cardTheme.color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: VERY_SMALL_SPACE),
            child: Text(
              question.value!,
              style: theme.textTheme.headlineMedium?.apply(
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
