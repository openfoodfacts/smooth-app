import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

void main() {
  group('ProductNutritionExtension', () {
    test('reads the value per 100g', () {
      final Product product = Product(
        nutriments: Nutriments.empty()
          ..setValue(Nutrient.fat, PerSize.oneHundredGrams, 12.5)
          ..setValue(Nutrient.sugars, PerSize.serving, 3),
      );
      expect(product.getNutrientValuePer100(Nutrient.fat), 12.5);
      expect(product.getNutrientValuePer100(Nutrient.sugars), isNull);
      expect(product.getNutrientValuePer100(Nutrient.salt), isNull);
      expect(product.hasNutritionData, isTrue);
    });

    test('has no data without nutriments', () {
      expect(Product().getNutrientValuePer100(Nutrient.fat), isNull);
      expect(Product().hasNutritionData, isFalse);
    });

    test('has no data with empty nutriments', () {
      final Product product = Product(nutriments: Nutriments.empty());
      expect(product.hasNutritionData, isFalse);
    });
  });
}
