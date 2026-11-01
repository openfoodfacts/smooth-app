import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

const String _packaging = 'packaging';
const String _manufacturer = 'manufacturer';

final NumberFormat _format = NutritionContainerHelper.getNumberFormat('en');

final OrderedNutrients _orderedNutrients = OrderedNutrients(
  nutrients: <OrderedNutrient>[
    for (final String id in <String>[
      'energy-kj',
      'fat',
      'sugars',
      'iron',
      'vitamin-b9',
      'copper',
    ])
      OrderedNutrient(
        important: true,
        id: id,
        unit: 'g',
        displayInEditForm: true,
        name: id,
      ),
  ],
);

Map<String, dynamic> _value(final String unit, final String valueString) =>
    <String, dynamic>{
      'unit': unit,
      'value': num.parse(valueString),
      'value_string': valueString,
    };

Map<String, dynamic> _set(
  final String source,
  final String per,
  final Map<String, Map<String, dynamic>> nutrients, {
  final String preparation = 'as_sold',
}) => <String, dynamic>{
  'source': source,
  'preparation': preparation,
  'per': per,
  'nutrients': nutrients,
};

NutritionContainerHelper _helper(
  final List<Map<String, dynamic>> sets, {
  final String? servingSize,
  final bool? noNutritionData,
}) => NutritionContainerHelper(
  orderedNutrients: _orderedNutrients,
  product: Product(barcode: '1', servingSize: servingSize)
    ..nutrition = <String, dynamic>{
      'input_sets': sets,
      'no_nutrition_data_on_packaging': ?noNutritionData,
    },
);

void _type(
  final NutritionContainerHelper helper,
  final PerSize line,
  final Nutrient nutrient,
  final String text,
) => helper.setNutrientValueText(line, nutrient, text, _format);

String? _body(final NutritionContainerHelper helper) {
  final List<Product> products = helper.getChangedProducts('1');
  return products.isEmpty || products.first.nutrition == null
      ? null
      : jsonEncode(products.first.nutrition);
}

String _expected(final List<Map<String, dynamic>> inputSets) =>
    jsonEncode(<String, dynamic>{'input_sets': inputSets});

void main() {
  test('NutritionContainerHelper number format suits the input field', () {
    for (final String locale in <String>['en', 'fr']) {
      final NumberFormat format = NutritionContainerHelper.getNumberFormat(
        locale,
      );
      expect(() => DecimalSeparatorRewriter(format), returnsNormally);
      expect(
        format.format(1.6042e-06),
        locale == 'en' ? '0.0000016' : '0,0000016',
      );
    }
  });

  group('NutritionContainerHelper load', () {
    test('reads the packaging values and units', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100g', <String, Map<String, dynamic>>{
          'fat': _value('g', '12.5'),
          'iron': _value('mg', '5'),
        }),
      ]);
      expect(helper.perSize, PerSize.oneHundredGrams);
      expect(helper.getValue(Nutrient.fat), 12.5);
      expect(helper.getValue(Nutrient.iron), 5);
      expect(helper.getUnit(Nutrient.iron), Unit.MILLI_G);
      expect(helper.getUnit(Nutrient.sugars), Unit.G);
    });

    test('falls back on the manufacturer, nutrient by nutrient', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100g', <String, Map<String, dynamic>>{
          'fat': _value('g', '1'),
        }),
        _set(_manufacturer, '100g', <String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
          'copper': _value('mg', '0.5'),
          'iron': <String, dynamic>{'unit': 'mg', 'value_computed': 0.048},
        }),
      ]);
      expect(helper.getValue(Nutrient.fat), 1);
      expect(helper.getValue(Nutrient.copper), 0.5);
      expect(helper.getUnit(Nutrient.copper), Unit.MILLI_G);
      expect(helper.isFromManufacturer(Nutrient.fat), isFalse);
      expect(helper.isFromManufacturer(Nutrient.copper), isTrue);
      expect(helper.isFromManufacturer(Nutrient.sugars), isFalse);
      expect(helper.getValue(Nutrient.iron), isNull);
      expect(helper.isFromManufacturer(Nutrient.iron), isFalse);
    });

    test('ignores prepared and estimate sets', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, 'serving', <String, Map<String, dynamic>>{
          'fat': _value('g', '1'),
        }, preparation: 'prepared'),
        _set('estimate', '100g', <String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
        }),
      ]);
      expect(helper.getValue(Nutrient.fat), isNull);
    });

    test('reads each line from its own set and opens on the filled one', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, 'serving', <String, Map<String, dynamic>>{
          'fat': _value('g', '8'),
        }),
      ]);
      expect(helper.perSize, PerSize.serving);
      expect(helper.getValue(Nutrient.fat), 8);
      helper.perSize = PerSize.oneHundredGrams;
      expect(helper.getValue(Nutrient.fat), isNull);
    });

    test('shows a stored exponent without exponent', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100g', <String, Map<String, dynamic>>{
          'vitamin-b9': <String, dynamic>{
            'unit': 'g',
            'value': 3.1e-05,
            'value_string': '3.1e-05',
          },
        }),
      ]);
      expect(_format.format(helper.getValue(Nutrient.vitaminB9)), '0.000031');
    });

    test('computes energy in kJ from kcal', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100g', <String, Map<String, dynamic>>{
          'energy-kcal': _value('kcal', '100'),
        }),
      ]);
      expect(helper.getValue(Nutrient.energyKJ), 419);
    });

    test('reads the no nutrition data flag', () {
      expect(_helper(<Map<String, dynamic>>[]).noNutritionData, isFalse);
      expect(
        _helper(
          <Map<String, dynamic>>[],
          noNutritionData: true,
        ).noNutritionData,
        isTrue,
      );
    });
  });

  group('NutritionContainerHelper save', () {
    final List<Map<String, dynamic>> sets = <Map<String, dynamic>>[
      _set(_packaging, '100g', <String, Map<String, dynamic>>{
        'fat': _value('g', '12.5'),
        'iron': _value('mg', '5'),
        'vitamin-b9': _value('µg', '30'),
      }),
      _set(_packaging, 'serving', <String, Map<String, dynamic>>{
        'fat': _value('g', '8'),
      }),
      _set(_manufacturer, '100g', <String, Map<String, dynamic>>{
        'copper': _value('mg', '0.5'),
      }),
    ];

    test('sends nothing when nothing changed', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.fat, '12.5');
      expect(helper.getChangedProducts('1'), isEmpty);
    });

    test('sends only the changed nutrient, with its unit', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.iron, '6');
      expect(
        _body(helper),
        _expected(<Map<String, dynamic>>[
          <String, dynamic>{
            'per': '100g',
            'preparation': 'as_sold',
            'source': 'packaging',
            'nutrients': <String, dynamic>{
              'iron': <String, dynamic>{'unit': 'mg', 'value_string': '6'},
            },
          },
        ]),
      );
    });

    test('keeps micrograms and writes no exponent', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.vitaminB9, '0.000031');
      final String body = _body(helper)!;
      expect(
        body,
        contains('"vitamin-b9":{"unit":"µg","value_string":"0.000031"}'),
      );
      expect(body.contains('e-'), isFalse);
    });

    test('sends the new unit with the unchanged value', () {
      final NutritionContainerHelper helper = _helper(sets);
      helper.setNutrientUnit(Nutrient.iron, Unit.MICRO_G);
      expect(
        _body(helper),
        contains('"iron":{"unit":"µg","value_string":"5"}'),
      );
    });

    test('keeps the stored modifier on a unit change', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100g', <String, Map<String, dynamic>>{
          'fat': <String, dynamic>{..._value('g', '0.5'), 'modifier': '<'},
        }),
      ]);
      helper.setNutrientUnit(Nutrient.fat, Unit.MILLI_G);
      expect(
        _body(helper),
        contains('"fat":{"unit":"mg","value_string":"0.5","modifier":"<"}'),
      );
    });

    test('ignores text that is not a number', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.fat, '1.2.3');
      expect(helper.getChangedProducts('1'), isEmpty);
    });

    test('clears a nutrient that is not specified', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.fat, '-');
      expect(_body(helper), contains('"fat":{"unit":"g","value_string":""}'));
    });

    test('clears a nutrient with an empty value string', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.fat, '');
      expect(_body(helper), contains('"fat":{"unit":"g","value_string":""}'));
    });

    test('ignores a unit change on an empty nutrient', () {
      final NutritionContainerHelper helper = _helper(sets);
      helper.setNutrientUnit(Nutrient.sugars, Unit.MILLI_G);
      expect(helper.getChangedProducts('1'), isEmpty);
    });

    test('writes the serving line to the serving set only', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.serving, Nutrient.fat, '9');
      expect(
        _body(helper),
        _expected(<Map<String, dynamic>>[
          <String, dynamic>{
            'per': 'serving',
            'preparation': 'as_sold',
            'source': 'packaging',
            'nutrients': <String, dynamic>{
              'fat': <String, dynamic>{'unit': 'g', 'value_string': '9'},
            },
          },
        ]),
      );
    });

    test('writes an edited manufacturer value to the packaging set', () {
      final NutritionContainerHelper helper = _helper(sets);
      _type(helper, PerSize.oneHundredGrams, Nutrient.copper, '0.6');
      final String body = _body(helper)!;
      expect(body, contains('"source":"packaging"'));
      expect(body, isNot(contains('manufacturer')));
      expect(body, contains('"copper":{"unit":"mg","value_string":"0.6"}'));
    });

    test('keeps the 100ml line as 100ml', () {
      final NutritionContainerHelper helper = _helper(<Map<String, dynamic>>[
        _set(_packaging, '100ml', <String, Map<String, dynamic>>{
          'fat': _value('g', '1'),
        }),
      ]);
      _type(helper, PerSize.oneHundredGrams, Nutrient.fat, '2');
      expect(_body(helper), contains('"per":"100ml"'));
    });

    test('saves the serving size and the flag apart from the values', () {
      final NutritionContainerHelper helper = _helper(sets, servingSize: '30 g')
        ..setServingText('40 g')
        ..noNutritionData = true;
      _type(helper, PerSize.oneHundredGrams, Nutrient.iron, '6');
      final List<Product> products = helper.getChangedProducts('1');
      expect(products, hasLength(2));
      expect(products[0].servingSize, '40 g');
      expect(products[0].nutrition, isNotNull);
      expect(products[0].noNutritionData, isNull);
      expect(products[1].noNutritionData, isTrue);
      expect(products[1].nutrition, isNull);
    });

    test('does not send an unchanged serving size', () {
      final NutritionContainerHelper helper = _helper(sets, servingSize: '30 g')
        ..setServingText('30 g');
      expect(helper.getChangedProducts('1'), isEmpty);
    });
  });
}
