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

    test('GTIN-14 wrapping an EAN-8 is normalized to EAN-8', () {
      final GS1Barcode? barcode = tryParseGs1Barcode('(01)00000021000003');
      expect(barcode, isNotNull);
      expect(barcode!.normalizedGtin, '21000003');
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
    for (final String code in <String>[
      '21000003',
      '210000000010',
      '2100000000005',
    ]) {
      test('Checksum-valid UPC/EAN $code takes precedence over AI 21', () {
        // Each value is also a valid GS1 serial number, so parsing alone
        // cannot distinguish its symbology.
        expect(tryParseGs1Barcode(code)!.getAIRawData('21'), code.substring(2));
        final String normalized = normalizeScannedBarcode('  $code  ');
        expect(normalized, code == '210000000010' ? '0210000000010' : code);
      });

      for (final String explicitGs1 in <String>[
        '(21)${code.substring(2)}',
        ']C1$code',
        '^$code',
        '\x1D$code',
        '\u241D$code',
      ]) {
        test('Explicit GS1 $explicitGs1 overrides UPC/EAN ambiguity', () {
          final GS1Barcode? parsed = tryParseGs1Barcode(explicitGs1);
          expect(parsed, isNotNull);
          expect(parsed!.gtin, isNull);
          expect(parsed.getAIRawData('21'), code.substring(2));
          // Without a GTIN the cleaned value is used as key.
          expect(normalizeScannedBarcode(explicitGs1), isNotEmpty);
        });
      }
    }

    for (final String code in <String>[
      '17270101',
      '101234567890',
      '2112345678901',
    ]) {
      test('Numeric GS1 $code without AI 01 keeps its value', () {
        expect(normalizeScannedBarcode(code), code);
        final GS1Barcode? parsed = tryParseGs1Barcode(code);
        expect(parsed, isNotNull);
        expect(parsed!.gtin, isNull);
        expect(parsed.getAIRawData(code.substring(0, 2)), code.substring(2));
      });
    }

    test('GS1 barcode is keyed by normalized GTIN', () {
      expect(
        normalizeScannedBarcode('010426039255010117270101'),
        '4260392550101',
      );
    });

    test('EAN-8 wrapped in GTIN-14 is keyed by EAN-8', () {
      expect(normalizeScannedBarcode('(01)00000021000003'), '21000003');
      expect(normalizeScannedBarcode('21000003'), '21000003');
    });

    test('Traditional barcode is used as-is', () {
      expect(normalizeScannedBarcode('7622210631111'), '7622210631111');
    });

    test('Traditional barcode with dashes is fixed', () {
      expect(normalizeScannedBarcode('762220-123456'), '0762220123456');
    });

    test('UPC-A barcode is padded to EAN-13', () {
      expect(normalizeScannedBarcode('762220123456'), '0762220123456');
    });

    test('Barcode with surrounding spaces is trimmed', () {
      expect(normalizeScannedBarcode('  7622210631111  '), '7622210631111');
    });

    test('GS1 barcode without GTIN keeps the raw value', () {
      expect(normalizeScannedBarcode('10ABC123'), '10ABC123');
    });

    test('Bracketed GS1 barcode is keyed by normalized GTIN', () {
      expect(
        normalizeScannedBarcode('(01)04260392550101(17)270101'),
        '4260392550101',
      );
    });

    test('GS1 barcode with FNC1 markers and spaces is normalized', () {
      expect(
        normalizeScannedBarcode('  ^010426039255010117270101  '),
        '4260392550101',
      );
    });

    test('GS1 barcode without GTIN uses the cleaned value as key', () {
      expect(normalizeScannedBarcode('(10)ABC123'), '10ABC123');
    });

    test('Non-digit GTIN input never throws', () {
      expect(
        normalizeScannedBarcode('https://x.y/01/00x12345678901'),
        isNotEmpty,
      );
      expect(normalizeScannedBarcode('+123456789012'), '+123456789012');
      expect(normalizeScannedBarcode('0x12345678901'), '0x12345678901');
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
