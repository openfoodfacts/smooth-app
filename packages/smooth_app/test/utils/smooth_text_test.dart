import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/widgets/smooth_text.dart' show StringExtension;

void main() {
  group('Smooth text', () {
    group('String extension', () {
      test('Remove diacritics (oeuf)', () {
        expect('œuf'.removeDiacritics(), equals('oeuf'));
      });
      test('Comparison Safe String', () {
        expect('œuF'.getComparisonSafeString(), equals('oeuf'));
      });
    });
  });
}
