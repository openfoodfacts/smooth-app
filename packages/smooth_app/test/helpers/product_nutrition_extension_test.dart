import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

Map<String, dynamic> _set(
  Map<String, Map<String, dynamic>> nutrients, {
  String source = 'packaging',
  String preparation = 'as_sold',
  String per = '100g',
}) => <String, dynamic>{
  'source': source,
  'preparation': preparation,
  'per': per,
  'nutrients': nutrients,
};

Product _product(List<Map<String, dynamic>> sets) =>
    Product()..nutrition = <String, dynamic>{'input_sets': sets};

/// Same as a value saved by the app: no number, only the string.
Map<String, dynamic> _value(String unit, String value) => <String, dynamic>{
  'unit': unit,
  'value_string': value,
};

List<Object?> _get(
  Product product,
  Nutrient nutrient, [
  PerSize perSize = PerSize.oneHundredGrams,
]) {
  final NutritionValue? value = product.getNutrientValue(nutrient, perSize);
  return <Object?>[value?.value, value?.unit];
}

void main() {
  group('ProductNutritionExtension', () {
    final Product product = _product(<Map<String, dynamic>>[
      _set(<String, Map<String, dynamic>>{
        'fat': <String, dynamic>{
          'unit': 'g',
          'value': 12.5,
          'value_string': '12.5',
        },
        'iron': _value('mg', '5'),
        'vitamin-b9': _value('µg', '30'),
      }),
      _set(<String, Map<String, dynamic>>{
        'fat': _value('g', '4'),
      }, per: 'serving'),
    ]);

    test('reads the value and the unit as entered', () {
      expect(_get(product, Nutrient.fat), <Object?>[12.5, Unit.G]);
      expect(_get(product, Nutrient.iron), <Object?>[5, Unit.MILLI_G]);
      expect(_get(product, Nutrient.vitaminB9), <Object?>[30, Unit.MICRO_G]);
      expect(product.hasNutritionData, isTrue);
    });

    test('reads the set of the per size', () {
      expect(_get(product, Nutrient.fat, PerSize.serving), <Object?>[
        4,
        Unit.G,
      ]);
      expect(_get(product, Nutrient.iron, PerSize.serving), <Object?>[
        null,
        null,
      ]);
    });

    test('computes energy in kJ from kcal', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'energy-kcal': _value('kcal', '100'),
        }),
      ]);
      expect(_get(product, Nutrient.energyKJ), <Object?>[419, Unit.KJ]);
    });

    test('reads only the packaging set, as sold', () {
      final Product product = _product(<Map<String, dynamic>>[
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '1'),
        }, source: 'manufacturer'),
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '2'),
        }, source: 'estimate'),
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '3'),
        }, preparation: 'prepared'),
        _set(<String, Map<String, dynamic>>{
          'fat': _value('g', '4'),
        }, per: '100ml'),
      ]);
      expect(_get(product, Nutrient.fat), <Object?>[null, null]);
      expect(product.hasNutritionData, isFalse);
    });

    test('has no data without nutrition', () {
      expect(_get(Product(), Nutrient.fat), <Object?>[null, null]);
      expect(Product().hasNutritionData, isFalse);
    });

    group('old nutriments', () {
      // Saved by an older app version, in grams.
      final Product oldProduct = Product()
        // ignore: deprecated_member_use
        ..nutriments = (Nutriments.empty()
          ..setValue(Nutrient.fat, PerSize.oneHundredGrams, 12.5)
          ..setValue(Nutrient.iron, PerSize.oneHundredGrams, 0.005));

      test('are read in grams', () {
        expect(oldProduct.hasNutritionData, isTrue);
        expect(_get(oldProduct, Nutrient.fat), <Object?>[12.5, Unit.G]);
        expect(_get(oldProduct, Nutrient.iron), <Object?>[0.005, Unit.G]);
      });

      test('are overridden by the new values, nutrient by nutrient', () {
        final Product product =
            _product(<Map<String, dynamic>>[
                _set(<String, Map<String, dynamic>>{'fat': _value('g', '3')}),
              ])
              // ignore: deprecated_member_use
              ..nutriments = oldProduct.nutriments;
        expect(_get(product, Nutrient.fat), <Object?>[3, Unit.G]);
        expect(_get(product, Nutrient.iron), <Object?>[0.005, Unit.G]);
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
