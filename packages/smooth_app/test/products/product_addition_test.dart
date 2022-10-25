import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/model/Nutrient.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/model/PerSize.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'test_configs.dart';

void main() async {
  OpenFoodAPIConfiguration.globalQueryType = QueryType.TEST;

  group('Add New Products', () {
    const String barcode = '1010101010011';
    const String quantity = '300g';
    const String servingSize = '100g';
    const double servingQuantity = 100.0;

    const PerSize perSize = PerSize.oneHundredGrams;
    final Nutriments nutriments = Nutriments.empty()
      ..setValue(Nutrient.salt, perSize, 1)
      ..setValue(Nutrient.sugars, perSize, 1)
      ..setValue(Nutrient.calcium, perSize, 1)
      ..setValue(Nutrient.cholesterol, perSize, 1);

    final Product product = Product(
      barcode: barcode,
      productName: 'Test Product',
      quantity: quantity,
      servingSize: servingSize,
      servingQuantity: servingQuantity,
      lang: OpenFoodFactsLanguage.ENGLISH,
      brands: 'Test Brand',
      nutrimentEnergyUnit: 'kJ',
      nutrimentDataPer: PerSize.serving.offTag,
      ingredientsText: 'test1 (10%), test2 (20%), test3 (30%), test4, test4',
      nutriments: nutriments,
      additives: Additives(<String>['en: t123d'], <String>['E123D']),
    );

    test('Save test poduct without login', () async {
      final Status status =
          await OpenFoodAPIClient.saveProduct(anonymousUser(), product);
      expect(status.status, 400);
    });

    test('Save test product', () async {
      final Status status = await OpenFoodAPIClient.saveProduct(
        TestConfigs.TEST_USER,
        product,
        queryType: QueryType.TEST,
      );
      expect(status.status, 1);

      final ProductQueryConfiguration config = ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: <ProductField>[ProductField.ALL],
      );
      final ProductResult productResult = await OpenFoodAPIClient.getProduct(
        config,
        user: TestConfigs.TEST_USER,
        queryType: QueryType.TEST,
      );

      matchProduct(product, productResult);
    });
  });
}

void matchProduct(Product originalProduct, ProductResult productResult) {
  expect(productResult.status, 1);
  expect(productResult.barcode != null, true);
  expect(productResult.barcode, originalProduct.barcode);
  expect(productResult.product != null, true);
  expect(productResult.product!.barcode != null, true);
  expect(productResult.product!.barcode, originalProduct.barcode);

  expect(productResult.product!.quantity != null, true);
  expect(productResult.product!.quantity, originalProduct.quantity);
  expect(productResult.product!.servingQuantity != null, true);
  expect(
      productResult.product!.servingQuantity, originalProduct.servingQuantity);
  expect(productResult.product!.servingSize != null, true);
  expect(productResult.product!.servingSize, originalProduct.servingSize);

  expect(productResult.product!.nutriments != null, true);

  const PerSize perSize = PerSize.oneHundredGrams;

  expect(
      productResult.product!.nutriments!.getValue(Nutrient.salt, perSize) !=
          null,
      true);

  expect(originalProduct.nutriments!.getValue(Nutrient.salt, perSize),
      productResult.product!.nutriments!.getValue(Nutrient.salt, perSize));
  expect(
      productResult.product!.nutriments!.getValue(Nutrient.sugars, perSize) !=
          null,
      true);

  expect(originalProduct.nutriments!.getValue(Nutrient.sugars, perSize),
      productResult.product!.nutriments!.getValue(Nutrient.sugars, perSize));
  expect(
      productResult.product!.nutriments!.getValue(Nutrient.calcium, perSize) !=
          null,
      true);

  expect(originalProduct.nutriments!.getValue(Nutrient.calcium, perSize),
      productResult.product!.nutriments!.getValue(Nutrient.calcium, perSize));

  expect(
      productResult.product!.nutriments!
              .getValue(Nutrient.cholesterol, perSize) !=
          null,
      true);

  expect(
      originalProduct.nutriments!.getValue(Nutrient.cholesterol, perSize),
      productResult.product!.nutriments!
          .getValue(Nutrient.cholesterol, perSize));
}
