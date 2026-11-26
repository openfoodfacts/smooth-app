import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/robotoff_question_helper.dart';

void main() {
  group('RobotoffQuestionsEquality', () {
    final RobotoffQuestionsEquality equality = RobotoffQuestionsEquality();

    const RobotoffQuestion question1 = RobotoffQuestion(
      insightId: 'id-1',
      barcode: '12345678',
    );
    const RobotoffQuestion question1Duplicate = RobotoffQuestion(
      insightId: 'id-1',
      barcode: '99999999',
    );
    const RobotoffQuestion question2 = RobotoffQuestion(
      insightId: 'id-2',
      barcode: '12345678',
    );

    test('equals', () {
      expect(equality.equals(question1, question1), isTrue);
      expect(equality.equals(question1, question1Duplicate), isTrue);
      expect(equality.equals(question1, question2), isFalse);
    });

    test('hash', () {
      expect(
        equality.hash(question1),
        equals(equality.hash(question1Duplicate)),
      );
      expect(equality.hash(question1), equals('id-1'.hashCode));
    });

    test('isValidKey', () {
      expect(equality.isValidKey(question1), isTrue);
      expect(equality.isValidKey(question2), isTrue);
      expect(equality.isValidKey(null), isFalse);
      expect(equality.isValidKey('some_string'), isFalse);
      expect(equality.isValidKey(123), isFalse);
      expect(equality.isValidKey(<String>[]), isFalse);
      expect(equality.isValidKey(<String, dynamic>{}), isFalse);
    });
  });

  group('RobotoffQuestionHelper extension', () {
    const RobotoffQuestion q1 = RobotoffQuestion(insightId: 'id-1');
    const RobotoffQuestion q2 = RobotoffQuestion(insightId: 'id-2');
    const RobotoffQuestion q3 = RobotoffQuestion(insightId: 'id-3');

    test('areSameAs with empty lists', () {
      expect(<RobotoffQuestion>[].areSameAs(<RobotoffQuestion>[]), isTrue);
    });

    test('areSameAs with identical questions', () {
      expect(
        <RobotoffQuestion>[q1, q2].areSameAs(<RobotoffQuestion>[q1, q2]),
        isTrue,
      );
    });

    test('areSameAs with different order', () {
      expect(
        <RobotoffQuestion>[q1, q2].areSameAs(<RobotoffQuestion>[q2, q1]),
        isFalse,
      );
    });

    test('areSameAs with different lengths', () {
      expect(
        <RobotoffQuestion>[q1, q2].areSameAs(<RobotoffQuestion>[q1]),
        isFalse,
      );
    });

    test('areSameAs with different questions', () {
      expect(
        <RobotoffQuestion>[q1, q2].areSameAs(<RobotoffQuestion>[q1, q3]),
        isFalse,
      );
    });
  });
}
