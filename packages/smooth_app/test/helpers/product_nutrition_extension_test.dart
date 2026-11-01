import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

Product _product(
  final Map<String, Map<String, dynamic>> nutrients, {
  final String preparation = 'as_sold',
}) => Product()
  ..nutrition = <String, dynamic>{
    'aggregated_set': <String, dynamic>{
      'per': '100g',
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
    test('reads weights in grams, whatever the stored unit', () {
      final Product product = _product(<String, Map<String, dynamic>>{
        'fat': _value('packaging', 'g', 12.5),
        'iron': _value('manufacturer', 'mg', 5),
        'vitamin-b9': _value('packaging', 'µg', 30),
        'energy-kj': _value('packaging', 'kJ', 1200),
      });
      expect(product.getNutrientValuePer100(Nutrient.fat), 12.5);
      expect(product.getNutrientValuePer100(Nutrient.iron), 0.005);
      expect(
        product.getNutrientValuePer100(Nutrient.vitaminB9),
        closeTo(0.00003, 1e-12),
      );
      expect(product.getNutrientValuePer100(Nutrient.energyKJ), 1200);
      expect(product.getNutrientValuePer100(Nutrient.salt), isNull);
      expect(product.hasNutritionData, isTrue);
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

    test('has no data without nutrition', () {
      expect(Product().getNutrientValuePer100(Nutrient.fat), isNull);
      expect(Product().hasNutritionData, isFalse);
    });
  });
}
