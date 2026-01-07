import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/helpers/string_extension.dart';
import 'package:smooth_app/helpers/strings_helper.dart';

void main() {
  const String demoText = 'Sentence';

  group('indexesOf tests', () {
    test(
      'Multiple occurrences (with case)',
      () => expect(demoText.indexesOf('e'), equals(<int>[1, 4, 7])),
    );

    test(
      'Multiple occurrence (without case)',
      () => expect(
        demoText.indexesOf('e', ignoreCase: true),
        equals(<int>[1, 4, 7]),
      ),
    );

    test(
      'No occurrence (without case)',
      () => expect(demoText.indexesOf('E'), equals(<int>[])),
    );

    test(
      'Multiple occurrences (without case)',
      () => expect(
        demoText.indexesOf('E', ignoreCase: true),
        equals(<int>[1, 4, 7]),
      ),
    );

    test(
      'No occurrence',
      () => expect(demoText.indexesOf('z'), equals(<int>[])),
    );
  });

  group('removeCharacterAt tests', () {
    test(
      'Position 0',
      () => expect(demoText.removeCharacterAt(0), equals('entence')),
    );

    test(
      'Position 1',
      () => expect(demoText.removeCharacterAt(1), equals('Sntence')),
    );

    test(
      'Last position',
      () => expect(demoText.removeCharacterAt(7), equals('Sentenc')),
    );

    test(
      'incorrect position (negative)',
      () => expect(() {
        demoText.removeCharacterAt(-1);
      }, throwsAssertionError),
    );

    test(
      'incorrect position (> text length)',
      () => expect(() {
        demoText.removeCharacterAt(8);
      }, throwsAssertionError),
    );
  });

  group('replaceAllIgnoreFirst tests', () {
    test(
      'No replacement (first)',
      () => expect('123.4'.replaceAllIgnoreFirst('.', ''), equals('123.4')),
    );

    test(
      '1 replacement',
      () => expect('1.23.4'.replaceAllIgnoreFirst('.', ''), equals('1.234')),
    );

    test(
      '2 replacements',
      () => expect('1.2.3.4'.replaceAllIgnoreFirst('.', ''), equals('1.234')),
    );
  });

  group('removeEmptySpaces tests', () {
    test('Empty string', () => expect(''.removeSpaces(), equals('')));
    test(
      'String with only spaces',
      () => expect('   '.removeSpaces(), equals('')),
    );
    test(
      'String with spaces at the beginning',
      () => expect('  123'.removeSpaces(), equals('123')),
    );
    test(
      'String with spaces at the middle',
      () => expect('1 2  3'.removeSpaces(), equals('123')),
    );
    test(
      'String with spaces at the end',
      () => expect('123   '.removeSpaces(), equals('123')),
    );
  });
}
