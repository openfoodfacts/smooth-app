import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';

void main() {
  group('ProductNutritionExtension', () {
    test('reads the value for the given size', () {
      final Product product = Product(
        nutriments: Nutriments.empty()
          ..setValue(Nutrient.fat, PerSize.oneHundredGrams, 12.5)
          ..setValue(Nutrient.sugars, PerSize.serving, 3),
      );
      expect(
        product.getNutrientValue(Nutrient.fat, PerSize.oneHundredGrams),
        12.5,
      );
      expect(product.getNutrientValue(Nutrient.fat, PerSize.serving), isNull);
      expect(product.getNutrientValue(Nutrient.sugars, PerSize.serving), 3);
      expect(
        product.getNutrientValue(Nutrient.sugars, PerSize.oneHundredGrams),
        isNull,
      );
      expect(
        product.getNutrientValue(Nutrient.salt, PerSize.oneHundredGrams),
        isNull,
      );
      expect(product.hasNutritionData, isTrue);
    });

    test('has no data without nutriments', () {
      expect(
        Product().getNutrientValue(Nutrient.fat, PerSize.oneHundredGrams),
        isNull,
      );
      expect(Product().hasNutritionData, isFalse);
    });

    test('has no data with empty nutriments', () {
      final Product product = Product(nutriments: Nutriments.empty());
      expect(product.hasNutritionData, isFalse);
    });
  });
}
