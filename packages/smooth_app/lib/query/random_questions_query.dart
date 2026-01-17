import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/questions_query.dart';
import 'package:smooth_app/query/random_questions_manager.dart';

/// Robotoff questions helper, for random product questions.
class RandomQuestionsQuery extends QuestionsQuery {
  @override
  Future<List<RobotoffQuestion>> getQuestions(
    final LocalDatabase localDatabase,
    final int count,
  ) async {
    randomQuestionsManager.setRequest(count);
    if (randomQuestionsManager.isExhausted) {
      return <RobotoffQuestion>[];
    }

    final RobotoffQuestionResult result = await RobotoffAPIClient.getQuestions(
      randomQuestionsManager.language,
      user: randomQuestionsManager.user,
      countries: <OpenFoodFactsCountry>[randomQuestionsManager.country],
      count: randomQuestionsManager.count,
      page: randomQuestionsManager.page,
      questionOrder: RobotoffQuestionOrder.popularity,
      serverType: ServerType.openFoodFacts,
    );

    final int resultCount = result.questions?.length ?? 0;
    randomQuestionsManager.setResultCount(resultCount);
    if (resultCount == 0) {
      return <RobotoffQuestion>[];
    }
    final List<String> barcodes = <String>[];
    for (final RobotoffQuestion question in result.questions!) {
      if (question.barcode != null) {
        barcodes.add(question.barcode!);
      }
    }
    if (barcodes.isNotEmpty) {
      await ProductRefresher().silentFetchAndRefreshList(
        barcodes: barcodes,
        localDatabase: localDatabase,
        productType: ProductType.food,
      );
    }
    return result.questions!;
  }
}
