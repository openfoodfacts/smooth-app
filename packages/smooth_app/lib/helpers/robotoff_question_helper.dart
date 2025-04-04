import 'package:collection/collection.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

extension RobotoffQuestionHelper on List<RobotoffQuestion> {
  bool areSameAs(List<RobotoffQuestion> questions) {
    return equals(questions, RobotoffQuestionsEquality());
  }
}

class RobotoffQuestionsEquality implements Equality<RobotoffQuestion> {
  @override
  bool equals(RobotoffQuestion e1, RobotoffQuestion e2) =>
      e1.insightId == e2.insightId;

  @override
  int hash(RobotoffQuestion e) => e.insightId.hashCode;

  @override
  bool isValidKey(Object? o) {
    if (o is RobotoffQuestion) {
      return true;
    }
    throw UnimplementedError();
  }
}
