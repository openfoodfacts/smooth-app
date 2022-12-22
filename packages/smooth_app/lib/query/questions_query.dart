import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/query/product_query.dart';

class QuestionsQuery {
  Future<List<RobotoffQuestion>> getQuestions() async {
    final User user = OpenFoodAPIConfiguration.globalUser!;
    final String lc = ProductQuery.getLanguage().code;

    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRandomRobotoffQuestion(
      lc,
      user,
      count: 3,
    );

    return result.questions ?? <RobotoffQuestion>[];
  }
}
