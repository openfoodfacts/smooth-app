import 'package:openfoodfacts/model/RobotoffQuestion.dart';
import 'package:smooth_app/database/dao_string_list_map.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/robotoff_questions_query.dart';

class RobotoffInsightHelper {
  const RobotoffInsightHelper(this._localDatabase);
  final LocalDatabase _localDatabase;
  Future<void> cacheInsightAnnotationVoted(
      String barcode, String insightId) async {
    await DaoStringListMap(_localDatabase).add(barcode, insightId);
  }

  Future<bool> haveInsightAnnotationsVoted(
      List<RobotoffQuestion> questions) async {
    final Map<String, List<String>> votedHist =
        await DaoStringListMap(_localDatabase).getAll();
    bool result = false;
    for (final String barcode in votedHist.keys) {
      final List<String> insights = votedHist[barcode] ?? <String>[];
      if (questions.every((RobotoffQuestion question) =>
          insights.contains(question.insightId))) {
        result = true;
        break;
      }
    }
    return result;
  }

  Future<void> removeInsightAnnotationsSavedForProdcut(String barcode) async {
    await DaoStringListMap(_localDatabase).removeKey(barcode);
  }

  Future<void> clearInsightAnnotationsSaved() async {
    final Map<String, List<String>> records =
        await DaoStringListMap(_localDatabase).getAll();
    for (final String barcode in records.keys) {
      final List<RobotoffQuestion> questions =
          await RobotoffQuestionsQuery(barcode)
              .getRobotoffQuestionsForProduct();
      if (questions.isEmpty) {
        await DaoStringListMap(_localDatabase).removeKey(barcode);
      }
    }
  }
}
