import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';

class QuestionsQuery {
  Future<List<RobotoffQuestion>> getQuestions() async {
    final User user = OpenFoodAPIConfiguration.globalUser!;

    // TODO(vaiton): Not to sure about this
    final String lc = OpenFoodAPIConfiguration.globalLanguages![0].code;

    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRandomRobotoffQuestion(
      lc,
      user,
      count: 3,
    );

    return result.questions ?? <RobotoffQuestion>[];
  }
}
