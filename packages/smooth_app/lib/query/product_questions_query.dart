import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/questions_query.dart';

/// Robotoff questions helper, for questions about a product.
class ProductQuestionsQuery extends QuestionsQuery {
  ProductQuestionsQuery(this.barcode);

  final String barcode;

  @override
  Future<List<RobotoffQuestion>> getQuestions(
    final LocalDatabase localDatabase,
    final int count,
  ) async {
    final RobotoffQuestionResult result =
        await RobotoffAPIClient.getProductQuestions(
          barcode,
          ProductQuery.getLanguage(),
          count: count,
        );
    if (result.questions?.isNotEmpty != true) {
      return <RobotoffQuestion>[];
    }
    await ProductRefresher().silentFetchAndRefresh(
      barcode: barcode,
      localDatabase: localDatabase,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
