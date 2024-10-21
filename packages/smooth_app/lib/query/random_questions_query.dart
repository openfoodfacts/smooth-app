import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/questions_query.dart';

/// Robotoff questions helper, for random product questions.
class RandomQuestionsQuery extends QuestionsQuery {
  @override
  Future<List<RobotoffQuestion>> getQuestions(
    final LocalDatabase localDatabase,
    final int count,
  ) async {
    final RobotoffQuestionResult result = await RobotoffAPIClient.getQuestions(
      ProductQuery.getLanguage(),
      user: ProductQuery.getReadUser(),
      countries: <OpenFoodFactsCountry>[ProductQuery.getCountry()],
      count: count,
      questionOrder: RobotoffQuestionOrder.random,
    );

    if (result.questions?.isNotEmpty != true) {
      return <RobotoffQuestion>[];
    }
    final List<String> barcodes = <String>[];
    for (final RobotoffQuestion question in result.questions!) {
      if (question.barcode != null) {
        barcodes.add(question.barcode!);
      }
    }
    await ProductRefresher().silentFetchAndRefreshList(
      barcodes: barcodes,
      localDatabase: localDatabase,
      productType: ProductType.food,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
