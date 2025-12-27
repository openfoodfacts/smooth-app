import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/helpers/barcode_utils.dart';

void main() {
  group('isBarcode - Traditional numeric barcodes', () {
    test('Valid 8-digit barcode', () => expect('12345678'.isBarcode, isTrue));

    test(
      'Valid 13-digit barcode (EAN-13)',
      () => expect('1234567890123'.isBarcode, isTrue),
    );

    test(
      'Valid 12-digit barcode (UPC-A)',
      () => expect('123456789012'.isBarcode, isTrue),
    );

    test(
      'Valid 14-digit barcode (GTIN-14)',
      () => expect('12345678901234'.isBarcode, isTrue),
    );

    test(
      'Valid long numeric barcode',
      () => expect('123456789012345678'.isBarcode, isTrue),
    );

    test(
      'Invalid 7-digit numeric string',
      () => expect('1234567'.isBarcode, isFalse),
    );

    test(
      'Invalid numeric string with letters',
      () => expect('12345678a'.isBarcode, isFalse),
    );

    test(
      'Invalid numeric string with spaces',
      () => expect('12345 678'.isBarcode, isFalse),
    );

    test(
      'Invalid numeric string with special characters',
      () => expect('12345-678'.isBarcode, isFalse),
    );
  });

  group('isBarcode - GS1 barcodes with FNC1 characters', () {
    test(
      r'Valid GS1 barcode with \x1D FNC1 character',
      () => expect('01123456789012\x1D17270101'.isBarcode, isTrue),
    );

    test(
      r'Valid GS1 barcode with \u241D FNC1 character',
      () => expect('01123456789012\u241D17270101'.isBarcode, isTrue),
    );

    test(
      'Valid GS1 barcode with multiple FNC1 characters',
      () => expect('01123456789012\x1D17270101\x1D10ABC123'.isBarcode, isTrue),
    );

    test(
      'Valid short string with FNC1 character',
      () => expect('01\x1D17'.isBarcode, isTrue),
    );

    test(
      'Valid GS1 barcode with mixed FNC1 characters',
      () => expect('01123456789012\x1D17270101\u241D10ABC'.isBarcode, isTrue),
    );
  });

  group('isBarcode - GS1 bracketed AI format', () {
    test(
      'Valid bracketed AI with 2-digit AI (GTIN)',
      () => expect('(01)04044782317112'.isBarcode, isTrue),
    );

    test(
      'Valid bracketed AI with expiration date',
      () => expect('(01)04044782317112(17)270101'.isBarcode, isTrue),
    );

    test(
      'Valid bracketed AI with 3-digit AI',
      () => expect('(310)123456'.isBarcode, isTrue),
    );

    test(
      'Valid bracketed AI with 4-digit AI',
      () => expect('(8005)12345'.isBarcode, isTrue),
    );

    test(
      'Valid complex bracketed AI format',
      () => expect(
        '(01)04044782317112(17)270101(10)ABC123(21)SERIAL'.isBarcode,
        isTrue,
      ),
    );

    test(
      'Valid bracketed AI with alphanumeric values',
      () => expect('(01)12345678901234(21)ABC-123-XYZ'.isBarcode, isTrue),
    );

    test(
      'Invalid bracketed format - missing closing bracket',
      () => expect('(01)04044782317112(17270101'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - missing opening bracket',
      () => expect('01)04044782317112(17)270101'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - empty AI',
      () => expect('()04044782317112'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - non-numeric AI',
      () => expect('(AB)04044782317112'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - single digit AI',
      () => expect('(1)04044782317112'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - AI too long (5 digits)',
      () => expect('(12345)04044782317112'.isBarcode, isFalse),
    );

    test(
      'Invalid bracketed format - empty value',
      () => expect('(01)(17)270101'.isBarcode, isFalse),
    );
  });

  group('isBarcode - GS1 Digital Links', () {
    test(
      'Valid HTTPS Digital Link with GTIN in path',
      () => expect('https://example.com/01/12345678901234'.isBarcode, isTrue),
    );

    test(
      'Valid HTTP Digital Link with GTIN in path',
      () => expect('http://example.com/01/12345678901234'.isBarcode, isTrue),
    );

    test(
      'Valid Digital Link with multiple AIs in path',
      () => expect(
        'https://example.com/01/12345678901234/17/270101'.isBarcode,
        isTrue,
      ),
    );

    test(
      'Valid Digital Link with AI in query parameter',
      () => expect(
        'https://example.com/product?01=12345678901234'.isBarcode,
        isTrue,
      ),
    );

    test(
      'Valid Digital Link with 3-digit AI',
      () => expect('https://example.com/310/123456'.isBarcode, isTrue),
    );

    test(
      'Valid Digital Link with 4-digit AI',
      () => expect('https://example.com/8005/12345'.isBarcode, isTrue),
    );

    test(
      'Valid Digital Link with mixed path and query AIs',
      () => expect(
        'https://example.com/01/12345678901234?21=SERIAL123'.isBarcode,
        isTrue,
      ),
    );

    test(
      'Invalid Digital Link - no AI pattern in path',
      () => expect(
        'https://example.com/product/12345678901234'.isBarcode,
        isFalse,
      ),
    );

    test(
      'Invalid Digital Link - AI but no value in path',
      () => expect('https://example.com/01/'.isBarcode, isFalse),
    );

    test(
      'Invalid Digital Link - single digit AI',
      () => expect('https://example.com/1/12345678901234'.isBarcode, isFalse),
    );

    test(
      'Invalid Digital Link - 5-digit AI',
      () =>
          expect('https://example.com/12345/12345678901234'.isBarcode, isFalse),
    );

    test(
      'Invalid URL - not a valid URL',
      () => expect('https://invalid url'.isBarcode, isFalse),
    );

    test(
      'Invalid URL - no AI in query parameter values',
      () => expect(
        'https://example.com/product?name=12345678901234'.isBarcode,
        isFalse,
      ),
    );
  });

  group('isBarcode - Edge cases', () {
    test('Empty string', () => expect(''.isBarcode, isFalse));

    test('String with only spaces', () => expect('   '.isBarcode, isFalse));

    test(
      'String with leading spaces (trimmed to valid barcode)',
      () => expect('  12345678  '.isBarcode, isTrue),
    );

    test(
      'String with leading spaces (trimmed to invalid string)',
      () => expect('  ABC  '.isBarcode, isFalse),
    );

    test('String with newlines', () => expect('1234\n5678'.isBarcode, isFalse));

    test('String with tabs', () => expect('12345\t678'.isBarcode, isFalse));

    test(
      'Mixed format - numeric followed by bracketed',
      () => expect('12345678(01)12345678901234'.isBarcode, isFalse),
    );

    test(
      'Mixed format - URL-like string without proper structure',
      () => expect('https://12345678'.isBarcode, isFalse),
    );

    test(
      'Very long numeric barcode',
      () => expect(('1' * 100).isBarcode, isTrue),
    );

    test('Null-like string value', () => expect('null'.isBarcode, isFalse));

    test('Boolean-like string value', () => expect('true'.isBarcode, isFalse));

    test(
      'Floating point number string',
      () => expect('12345678.90'.isBarcode, isFalse),
    );

    test(
      'Negative number string',
      () => expect('-12345678'.isBarcode, isFalse),
    );

    test(
      'Barcode with leading zeros',
      () => expect('00012345678'.isBarcode, isTrue),
    );

    test(
      'GS1 Digital Link with fragment',
      () => expect(
        'https://example.com/01/12345678901234#section'.isBarcode,
        isTrue,
      ),
    );

    test(
      'GS1 Digital Link with port',
      () => expect(
        'https://example.com:8080/01/12345678901234'.isBarcode,
        isTrue,
      ),
    );

    test(
      'Case sensitivity - HTTPS uppercase',
      () => expect('HTTPS://example.com/01/12345678901234'.isBarcode, isFalse),
    );
  });
}
