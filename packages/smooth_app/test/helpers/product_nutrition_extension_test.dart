import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

Map<String, dynamic> _set(
  Map<String, Map<String, dynamic>> nutrients, {
  String source = 'packaging',
  String preparation = 'as_sold',
  String per = '100g',
  num? perQuantity,
  String? perUnit,
}) => <String, dynamic>{
  'source': source,
  'preparation': preparation,
  'per': per,
  'per_quantity': ?perQuantity,
  'per_unit': ?perUnit,
  'nutrients': nutrients,
};

Product _product(List<Map<String, dynamic>> sets) =>
    Product()..nutrition = <String, dynamic>{'input_sets': sets};

Map<String, dynamic> _value(String unit, String value) => <String, dynamic>{
  'unit': unit,
  'value_string': value,
};

double? _per100(Product product, Nutrient nutrient) =>
    product.getNutrientValue(nutrient, PerSize.oneHundredGrams);

List<Object?> _asIs(Product product, Nutrient nutrient) {
  final NutritionValue? value = product.getNutrientValueAsIs(
    nutrient,
    PerSize.oneHundredGrams,
  );
  return <Object?>[value?.value, value?.unit];
}

void main() {
  group('ProductNutritionExtension', () {
    final Product product = _product(<Map<String, dynamic>>[
      _set(<String, Map<String, dynamic>>{
        'fat': _value('g', '12.5'),
        'iron': _value('mg', '5'),
        'vitamin-b9': _value('µg', '30'),
        'energy-kj': _value('kJ', '1200'),
      }),
    ]);

    test('reads grams as they are', () {
      expect(_per100(product, Nutrient.fat), 12.5);
      expect(product.hasNutritionData, isTrue);
    });

    test('converts milligrams to grams', () {
      expect(_per100(product, Nutrient.iron), 0.005);
    });

    test('converts micrograms to grams', () {
      expect(_per100(product, Nutrient.vitaminB9), closeTo(0.00003, 1e-12));
    });

    test('keeps energy in kJ', () {
      expect(_per100(product, Nutrient.energyKJ), 1200);
    });

    test('computes energy in kJ from kcal', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'energy-kcal': _value('kcal', '100'),
        }),
      ]);
      expect(_per100(product, Nutrient.energyKJ), 419);
    });

    test('prefers manufacturer kcal over packaging kJ', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'energy-kj': _value('kJ', '1000'),
        }),
        _set(<String, Map<String, dynamic>>{
          'energy-kcal': _value('kcal', '100'),
        }, source: 'manufacturer'),
      ]);
      expect(_per100(product, Nutrient.energyKJ), 419);
    });

    test('returns null for a missing nutrient', () {
      expect(_per100(product, Nutrient.salt), isNull);
    });

    test('prefers manufacturer values, then packaging values', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'iron': _value('mg', '6'),
          'zinc': _value('mg', '5'),
        }),
        _set(<String, Map<String, dynamic>>{
          'iron': _value('mg', '5'),
        }, source: 'manufacturer'),
      ]);
      expect(_per100(product, Nutrient.iron), 0.005);
      expect(_per100(product, Nutrient.zinc), 0.005);
    });

    test('ignores estimates and prepared values', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '1'),
        }, source: 'estimate'),
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
        }, preparation: 'prepared'),
      ]);
      expect(_per100(product, Nutrient.fat), isNull);
      expect(product.hasNutritionData, isFalse);
    });

    test('reads per 100ml as per 100g', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '3'),
        }, per: '100ml'),
      ]);
      expect(_per100(product, Nutrient.fat), 3);
    });

    test('scales a per serving value to 100', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(
          <String, Map<String, dynamic>>{'fat': _value('g', '8')},
          per: 'serving',
          perQuantity: 40,
          perUnit: 'g',
        ),
      ]);
      expect(_per100(product, Nutrient.fat), 20);
      expect(product.getNutrientValue(Nutrient.fat, PerSize.serving), 8);
    });

    test('prefers per 100g, then per serving, within a source', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(
          <String, Map<String, dynamic>>{'sugars': _value('g', '4')},
          per: 'serving',
          perQuantity: 40,
          perUnit: 'g',
        ),
        _set(<String, Map<String, dynamic>>{'sugars': _value('g', '9')}),
      ]);
      expect(_per100(product, Nutrient.sugars), 9);
    });

    test('prefers the source over the per', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{'fat': _value('g', '9')}),
        _set(
          <String, Map<String, dynamic>>{'fat': _value('g', '8')},
          source: 'manufacturer',
          per: 'serving',
          perQuantity: 40,
          perUnit: 'g',
        ),
      ]);
      expect(_per100(product, Nutrient.fat), 20);
    });

    test('scales a serving from 5 g, not below', () {
      Product withServing(num quantity) => _product(<Map<String, dynamic>>[
        _set(
          <String, Map<String, dynamic>>{'fat': _value('g', '1')},
          per: 'serving',
          perQuantity: quantity,
          perUnit: 'g',
        ),
      ]);
      expect(_per100(withServing(5), Nutrient.fat), 20);
      expect(_per100(withServing(4), Nutrient.fat), isNull);
    });

    test('keeps a percentage from a serving as it is', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(
          <String, Map<String, dynamic>>{'alcohol': _value('% vol', '5')},
          per: 'serving',
          perQuantity: 330,
          perUnit: 'ml',
        ),
      ]);
      expect(_per100(product, Nutrient.alcohol), 5);
    });

    test('reads a value computed by the server', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'salt': <String, dynamic>{'unit': 'g', 'value_computed': 0.5},
        }),
      ]);
      expect(_per100(product, Nutrient.salt), 0.5);
    });

    test('reads usda values after packaging values', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
          'sugars': _value('g', '3'),
        }, source: 'usda'),
        _set(<String, Map<String, dynamic>>{'fat': _value('g', '1')}),
      ]);
      expect(_per100(product, Nutrient.fat), 1);
      expect(_per100(product, Nutrient.sugars), 3);
    });

    test('has data with usda values only', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
        }, source: 'usda'),
      ]);
      expect(product.hasNutritionData, isTrue);
    });

    test('ignores a per 1kg set', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '10'),
        }, per: '1kg'),
      ]);
      expect(_per100(product, Nutrient.fat), isNull);
      expect(product.hasNutritionData, isTrue);
    });

    test('has data with as sold input values only', () {
      Product withInputSet(String source, String preparation) => _product(
        <Map<String, dynamic>>[
          _set(
            <String, Map<String, dynamic>>{'fat': _value('g', '8')},
            source: source,
            preparation: preparation,
            per: 'serving',
          ),
        ],
      );
      expect(withInputSet('packaging', 'as_sold').hasNutritionData, isTrue);
      expect(withInputSet('manufacturer', 'as_sold').hasNutritionData, isTrue);
      expect(withInputSet('estimate', 'as_sold').hasNutritionData, isFalse);
      expect(withInputSet('packaging', 'prepared').hasNutritionData, isFalse);
    });

    test('has no data without nutrition', () {
      expect(_per100(Product(), Nutrient.fat), isNull);
      expect(Product().hasNutritionData, isFalse);
    });

    test('keeps the unit as entered', () {
      expect(_asIs(product, Nutrient.iron), <Object?>[5, Unit.MILLI_G]);
      expect(_asIs(product, Nutrient.vitaminB9), <Object?>[30, Unit.MICRO_G]);
    });

    test('computes energy in kJ from kcal, in kJ', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'energy-kcal': _value('kcal', '100'),
        }),
      ]);
      expect(_asIs(product, Nutrient.energyKJ), <Object?>[419, Unit.KJ]);
    });

    test('scales a serving value in the unit as entered', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(
          <String, Map<String, dynamic>>{'sodium': _value('mg', '50')},
          per: 'serving',
          perQuantity: 25,
          perUnit: 'g',
        ),
      ]);
      expect(_asIs(product, Nutrient.sodium), <Object?>[200, Unit.MILLI_G]);
    });

    group('old nutriments', () {
      // Saved by an older app version: grams, no input sets.
      final Product oldProduct = Product()
        // ignore: deprecated_member_use
        ..nutriments = (Nutriments.empty()
          ..setValue(Nutrient.fat, PerSize.oneHundredGrams, 12.5)
          ..setValue(Nutrient.iron, PerSize.oneHundredGrams, 0.005)
          ..setValue(Nutrient.energyKCal, PerSize.oneHundredGrams, 100));

      test('are read when there are no input sets', () {
        expect(oldProduct.hasNutritionData, isTrue);
        expect(_per100(oldProduct, Nutrient.fat), 12.5);
        expect(_per100(oldProduct, Nutrient.iron), 0.005);
        expect(_asIs(oldProduct, Nutrient.iron), <Object?>[0.005, Unit.G]);
        expect(_per100(oldProduct, Nutrient.energyKJ), closeTo(418.68, 0.01));
      });

      test('win over input sets, as they are a pending older change', () {
        final Product product =
            _product(<Map<String, dynamic>>[
                _set(<String, Map<String, dynamic>>{'fat': _value('g', '3')}),
              ])
              // ignore: deprecated_member_use
              ..nutriments = oldProduct.nutriments;
        expect(_per100(product, Nutrient.fat), 12.5);
      });
    });

    test('no nutrition data: local change, then packaging', () {
      Product withFlag({bool? local, bool? onPackaging}) => Product()
        ..noNutritionData = local
        ..nutrition = <String, dynamic>{
          'no_nutrition_data_on_packaging': ?onPackaging,
        };
      expect(withFlag().hasNoNutritionData, isFalse);
      expect(withFlag(onPackaging: true).hasNoNutritionData, isTrue);
      expect(
        withFlag(local: false, onPackaging: true).hasNoNutritionData,
        isFalse,
      );
      expect(withFlag(local: true).hasNoNutritionData, isTrue);
    });
  });
}
