import 'package:flutter_test/flutter_test.dart';
import 'package:gs1_barcode_parser_plus/gs1_barcode_parser.dart';
import 'package:smooth_app/helpers/gs1_helper.dart';

void main() {
  group('tryParseGs1Barcode - non-GS1 input', () {
    test('Empty string', () => expect(tryParseGs1Barcode(''), isNull));

    test(
      'String with only spaces',
      () => expect(tryParseGs1Barcode('   '), isNull),
    );

    test(
      'Traditional EAN-13 barcode',
      () => expect(tryParseGs1Barcode('7622210631111'), isNull),
    );

    test(
      'Traditional UPC-A barcode',
      () => expect(tryParseGs1Barcode('762220123456'), isNull),
    );

    test(
      'Truncated GTIN (13 digits)',
      () => expect(tryParseGs1Barcode('0426039255010'), isNull),
    );

    test(
      'Non numeric string',
      () => expect(tryParseGs1Barcode('ABCD'), isNull),
    );

    test(
      'Very short string (2 chars)',
      () => expect(tryParseGs1Barcode('AB'), isNull),
    );

    test(
      'Very short string (3 chars)',
      () => expect(tryParseGs1Barcode('ABC'), isNull),
    );

    test(
      'Floating point number string',
      () => expect(tryParseGs1Barcode('12345678.90'), isNull),
    );
  });

  group('tryParseGs1Barcode - GS1 raw element strings', () {
    test('Raw element string with GTIN and expiry', () {
      final GS1Barcode? parsed = tryParseGs1Barcode('010426039255010117270101');
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.hasAI(GS1_AI_GTIN), isTrue);
      expect(barcode.gtin, '04260392550101');
      expect(barcode.normalizedGtin, '4260392550101');
      expect(barcode.hasAI('17'), isTrue);
    });

    test('Raw element string with GS separators', () {
      final GS1Barcode? parsed = tryParseGs1Barcode(
        '0104260392550101\x1D17270101\x1D10ABC123',
      );
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.normalizedGtin, '4260392550101');
      expect(barcode.hasAI('17'), isTrue);
      expect(barcode.hasAI('10'), isTrue);
    });

    test('Raw element string with FNC1 prefix', () {
      final GS1Barcode? barcode = tryParseGs1Barcode(
        ']C1010426039255010117270101',
      );
      expect(barcode, isNotNull);
      expect(barcode!.normalizedGtin, '4260392550101');
    });

    test('Raw element string with leading caret FNC1', () {
      final GS1Barcode? barcode = tryParseGs1Barcode(
        '^010426039255010117270101',
      );
      expect(barcode, isNotNull);
      expect(barcode!.normalizedGtin, '4260392550101');
    });

    test('Raw element string with serial number', () {
      final GS1Barcode? barcode = tryParseGs1Barcode(
        '0104260392550101\x1D21ABC-123',
      );
      expect(barcode, isNotNull);
      expect(barcode!.hasAI('21'), isTrue);
    });

    test('Raw element string with net weight', () {
      final GS1Barcode? barcode = tryParseGs1Barcode(
        '0104260392550101172601013103000526',
      );
      expect(barcode, isNotNull);
      expect(barcode!.hasAI('3103'), isTrue);
    });

    test('GTIN-14 without leading zero is kept as-is', () {
      final GS1Barcode? barcode = tryParseGs1Barcode('0114600439937620');
      expect(barcode, isNotNull);
      expect(barcode!.normalizedGtin, '14600439937620');
    });

    test('GTIN-14 with invalid EAN-13 check digit is kept as-is', () {
      final GS1Barcode? barcode = tryParseGs1Barcode(
        '010426039255010217270101',
      );
      expect(barcode, isNotNull);
      expect(barcode!.normalizedGtin, '04260392550102');
    });
  });

  group('tryParseGs1Barcode - bracketed AI format', () {
    test('Bracketed format is parsed', () {
      final GS1Barcode? parsed = tryParseGs1Barcode(
        '(01)04260392550101(17)270101',
      );
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.normalizedGtin, '4260392550101');
      expect(barcode.hasAI('17'), isTrue);
    });

    test('Bracketed format with missing closing bracket is rejected', () {
      expect(tryParseGs1Barcode('(01)04044782317112(17270101'), isNull);
    });

    test('Bracketed format with missing opening bracket is rejected', () {
      expect(tryParseGs1Barcode('01)04044782317112(17)270101'), isNull);
    });

    test('Single digit bracketed AI is rejected', () {
      expect(tryParseGs1Barcode('(1)04044782317112'), isNull);
    });

    test('Bracketed AI with an empty value is rejected', () {
      expect(tryParseGs1Barcode('(21)(17)270101'), isNull);
    });

    test('Non-final variable-length AI keeps following AIs', () {
      final GS1Barcode? parsed = tryParseGs1Barcode('(10)ABC123(17)270101');
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.getAIRawData('10'), 'ABC123');
      expect(barcode.hasAI('17'), isTrue);
    });

    test('Parentheses in variable-length AI values keep following AIs', () {
      final GS1Barcode? parsed = tryParseGs1Barcode('(21)AB(CD(17)270101');
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.getAIRawData('21'), 'AB(CD');
      expect(barcode.hasAI('17'), isTrue);
    });

    test('Complex bracketed format keeps all AIs', () {
      final GS1Barcode? parsed = tryParseGs1Barcode(
        '(01)04044782317112(17)270101(10)ABC123(21)SERIAL',
      );
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.gtin, '04044782317112');
      expect(barcode.getAIRawData('10'), 'ABC123');
      expect(barcode.getAIRawData('21'), 'SERIAL');
    });

    test('Raw element string with parentheses in AI value', () {
      final GS1Barcode? parsed = tryParseGs1Barcode('21AB(CD');
      expect(parsed, isNotNull);
      expect(parsed!.getAIRawData('21'), 'AB(CD');
    });
  });

  group('tryParseGs1Barcode - GS1 Digital Links', () {
    test('Digital Link URL is parsed', () {
      final GS1Barcode? parsed = tryParseGs1Barcode(
        'https://id.gs1.org/01/04260392550101/17/270101',
      );
      expect(parsed, isNotNull);
      final GS1Barcode barcode = parsed!;
      expect(barcode.normalizedGtin, '4260392550101');
      expect(barcode.hasAI('17'), isTrue);
    });
  });

  group('normalizeScannedBarcode', () {
    test('GS1 barcode is keyed by normalized GTIN', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '010426039255010117270101',
      );
      expect(normalized.key, '4260392550101');
      expect(normalized.gs1Barcode, isNotNull);
    });

    test('Traditional barcode is used as-is', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '7622210631111',
      );
      expect(normalized.key, '7622210631111');
      expect(normalized.gs1Barcode, isNull);
    });

    test('Traditional barcode with dashes is fixed', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '762220-123456',
      );
      expect(normalized.key, '0762220123456');
    });

    test('UPC-A barcode is padded to EAN-13', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '762220123456',
      );
      expect(normalized.key, '0762220123456');
    });

    test('Barcode with surrounding spaces is trimmed', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '  7622210631111  ',
      );
      expect(normalized.key, '7622210631111');
    });

    test('GS1 barcode without GTIN keeps the raw value', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode('10ABC123');
      expect(normalized.key, '10ABC123');
      expect(normalized.gs1Barcode, isNotNull);
    });

    test('Bracketed GS1 barcode is keyed by normalized GTIN', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '(01)04260392550101(17)270101',
      );
      expect(normalized.key, '4260392550101');
      expect(normalized.gs1Barcode, isNotNull);
    });

    test('GS1 barcode with FNC1 markers and spaces is normalized', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '  ^010426039255010117270101  ',
      );
      expect(normalized.key, '4260392550101');
    });

    test('GS1 barcode without GTIN uses the cleaned value as key', () {
      final NormalizedBarcode normalized = normalizeScannedBarcode(
        '(10)ABC123',
      );
      expect(normalized.key, '10ABC123');
      expect(normalized.gs1Barcode, isNotNull);
    });
  });

  group('fixTraditionalBarcode', () {
    test(
      'Trims the value',
      () => expect(fixTraditionalBarcode('  123456  '), '123456'),
    );

    test(
      'Removes dashes',
      () => expect(fixTraditionalBarcode('123-456'), '123456'),
    );

    test('Pads UPC-A to EAN-13', () {
      expect(fixTraditionalBarcode('762220123456'), '0762220123456');
    });

    test('Keeps EAN-13 unchanged', () {
      expect(fixTraditionalBarcode('7622210631111'), '7622210631111');
    });
  });
}
