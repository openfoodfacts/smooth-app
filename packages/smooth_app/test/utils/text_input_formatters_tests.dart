import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';

void main() {
  group('Replace separator', () {
    test('Enabled', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(rewriter.replaceSeparator('123,4'), equals('123,4'));
      expect(rewriter.replaceSeparator('123.4'), equals('123,4'));
      expect(rewriter.replaceSeparator('1,23,4'), equals('1,23,4'));
      expect(rewriter.replaceSeparator('1,23.4'), equals('1,23,4'));
      expect(rewriter.replaceSeparator('1.23.4'), equals('1,23,4'));
    });

    test('Disabled', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _noDecimalSeparator,
      );

      expect(rewriter.replaceSeparator('123,4'), equals('123,4'));
      expect(rewriter.replaceSeparator('123.4'), equals('123.4'));
      expect(rewriter.replaceSeparator('1,23,4'), equals('1,23,4'));
      expect(rewriter.replaceSeparator('1,23.4'), equals('1,23.4'));
      expect(rewriter.replaceSeparator('1.23.4'), equals('1.23.4'));
    });
  });

  group('Move separator', () {
    test('Existing separator', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1,234',
          '1,23,4',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '123,4',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('No separator', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1234',
          '1,234',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '1,234',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('Separator on first character', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1234',
          ',1234',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: ',1234',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('Separator on last character', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1234',
          '1234,',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '1234,',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('Multiples separators', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1234',
          '1,234,',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '1,234',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('Multiples separators', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1,234',
          '1,234,',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '1234,',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });

    test('Multiples separators', () {
      final DecimalSeparatorRewriter rewriter = DecimalSeparatorRewriter(
        _commaDecimalSeparator,
      );

      expect(
        rewriter.moveSeparator(
          '1,234',
          '1,2,34,',
          TextSelection.fromPosition(const TextPosition(offset: 0)),
        ),
        equals(
          const MoveSeparatorResult(
            newText: '1,234',
            newBasePosition: 0,
            newExtentPosition: 0,
          ),
        ),
      );
    });
  });
}

NumberFormat get _commaDecimalSeparator => NumberFormat('##.##', 'fr_FR');

NumberFormat get _noDecimalSeparator => NumberFormat('##.##', 'de_DE');
