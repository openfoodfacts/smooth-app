import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/widgets/smooth_text.dart' show StringExtension;

void main() {
  group('Smooth text', () {
    group('String extension', () {
      test('Remove accents', () {
        expect(
          'àáâãäåéèêëòóôõöìíîïùúûüñšÿýž'.removeAccents(),
          equals('aaaaaaeeeeoooooiiiiuuuunsyyz'),
        );
      });
      test('Remove diacritics', () {
        expect(
          'àáâãäåéèêëòóôõöìíîïùúûüñšÿýž'.removeDiacritics(),
          equals('aaaaaaeeeeoooooiiiiuuuunsyyz'),
        );
      });
    });
  });
}
