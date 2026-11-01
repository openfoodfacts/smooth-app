import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

Product _product(
  final Map<String, Map<String, dynamic>> nutrients, {
  final String preparation = 'as_sold',
  final String per = '100g',
}) => Product()
  ..nutrition = <String, dynamic>{
    'aggregated_set': <String, dynamic>{
      'per': per,
      'preparation': preparation,
      'nutrients': nutrients,
    },
  };

Map<String, dynamic> _value(
  final String source,
  final String unit,
  final num value,
) => <String, dynamic>{'source': source, 'unit': unit, 'value': value};

void main() {
  group('ProductNutritionExtension', () {
    final Product product = _product(<String, Map<String, dynamic>>{
      'fat': _value('packaging', 'g', 12.5),
      'iron': _value('manufacturer', 'mg', 5),
      'vitamin-b9': _value('packaging', 'µg', 30),
      'energy-kj': _value('packaging', 'kJ', 1200),
    });

    test('reads grams as they are', () {
      expect(product.getNutrientValuePer100(Nutrient.fat), 12.5);
      expect(product.hasNutritionData, isTrue);
    });

    test('converts milligrams to grams', () {
      expect(product.getNutrientValuePer100(Nutrient.iron), 0.005);
    });

    test('converts micrograms to grams', () {
      expect(
        product.getNutrientValuePer100(Nutrient.vitaminB9),
        closeTo(0.00003, 1e-12),
      );
    });

    test('keeps energy in kJ', () {
      expect(product.getNutrientValuePer100(Nutrient.energyKJ), 1200);
    });

    test('returns null for a missing nutrient', () {
      expect(product.getNutrientValuePer100(Nutrient.salt), isNull);
    });

    test('ignores estimates, except added sugars', () {
      final Product product = _product(<String, Map<String, dynamic>>{
        'fat': _value('estimate', 'g', 1),
        'added-sugars': _value('estimate', 'g', 2),
      });
      expect(product.getNutrientValuePer100(Nutrient.fat), isNull);
      expect(product.getNutrientValuePer100(Nutrient.addedSugars), 2);
      expect(product.hasNutritionData, isTrue);
    });

    test('has no data with estimates only', () {
      final Product product = _product(<String, Map<String, dynamic>>{
        'fat': _value('estimate', 'g', 1),
      });
      expect(product.hasNutritionData, isFalse);
    });

    test('ignores a prepared aggregate', () {
      final Product product = _product(<String, Map<String, dynamic>>{
        'fat': _value('packaging', 'g', 1),
      }, preparation: 'prepared');
      expect(product.getNutrientValuePer100(Nutrient.fat), isNull);
      expect(product.hasNutritionData, isFalse);
    });

    test('ignores a per 1kg aggregate', () {
      final Product product = _product(<String, Map<String, dynamic>>{
        'fat': _value('packaging', 'g', 10),
      }, per: '1kg');
      expect(product.getNutrientValuePer100(Nutrient.fat), isNull);
    });

    test('has data with as sold input values only', () {
      Product withInputSet(final String source, final String preparation) =>
          Product()
            ..nutrition = <String, dynamic>{
              'input_sets': <Map<String, dynamic>>[
                <String, dynamic>{
                  'source': source,
                  'preparation': preparation,
                  'per': 'serving',
                  'nutrients': <String, dynamic>{
                    'fat': <String, dynamic>{'unit': 'g', 'value_string': '8'},
                  },
                },
              ],
            };
      expect(withInputSet('packaging', 'as_sold').hasNutritionData, isTrue);
      expect(withInputSet('manufacturer', 'as_sold').hasNutritionData, isTrue);
      expect(withInputSet('estimate', 'as_sold').hasNutritionData, isFalse);
      expect(withInputSet('packaging', 'prepared').hasNutritionData, isFalse);
    });

    test('has no data without nutrition', () {
      expect(Product().getNutrientValuePer100(Nutrient.fat), isNull);
      expect(Product().hasNutritionData, isFalse);
    });
  });
}
