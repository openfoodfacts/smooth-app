import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

class QuestionsQuery {
  Future<List<RobotoffQuestion>> getQuestions() async {
    final RobotoffQuestionResult result =
        await RobotoffAPIClient.getRandomQuestions(
      ProductQuery.getLanguage(),
      OpenFoodAPIConfiguration.globalUser,
      count: 3,
    );

    return result.questions ?? <RobotoffQuestion>[];
  }
}
