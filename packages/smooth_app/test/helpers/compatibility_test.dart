import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/food_preferences/preferences_page_projects.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/product_for_me_attributes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUp(() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    userPreferences = await UserPreferences.getUserPreferences();
    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
      userPreferences: userPreferences,
    );
  });

  group('UserPreferences project-scoped importance', () {
    test('beauty preferences are isolated from food preferences', () async {
      await userPreferences.setImportanceForProject(
        'vegan',
        PreferenceImportance.ID_MANDATORY,
        PreferencesPageProjects.beauty,
      );

      expect(
        userPreferences.getImportanceForProject(
          'vegan',
          PreferencesPageProjects.beauty,
        ),
        PreferenceImportance.ID_MANDATORY,
      );
      expect(
        userPreferences.getImportanceForProject(
          'vegan',
          PreferencesPageProjects.food,
        ),
        PreferenceImportance.ID_NOT_IMPORTANT,
      );
      expect(
        userPreferences.getImportance('vegan', productType: ProductType.beauty),
        PreferenceImportance.ID_MANDATORY,
      );
      expect(
        userPreferences.getImportance('vegan', productType: ProductType.food),
        PreferenceImportance.ID_NOT_IMPORTANT,
      );
    });

    test('food preferences fallback to legacy keys', () async {
      await userPreferences.setImportance(
        'palm_oil',
        PreferenceImportance.ID_MANDATORY,
      );

      expect(
        userPreferences.getImportanceForProject(
          'palm_oil',
          PreferencesPageProjects.food,
        ),
        PreferenceImportance.ID_MANDATORY,
      );
      expect(
        userPreferences.getImportance(
          'palm_oil',
          productType: ProductType.food,
        ),
        PreferenceImportance.ID_MANDATORY,
      );
      expect(
        userPreferences.arePreferencesSetForProject(
          PreferencesPageProjects.food,
        ),
        isTrue,
      );
    });
  });

  group('ProductPreferences scoped manager and MatchedProductV2', () {
    test('resolves cosmetics attributes with beauty preferences', () async {
      await userPreferences.setImportanceForProject(
        'vegan',
        PreferenceImportance.ID_MANDATORY,
        PreferencesPageProjects.beauty,
      );

      final Product beautyProduct = Product(barcode: '111111')
        ..productType = ProductType.beauty
        ..attributeGroups = <AttributeGroup>[
          AttributeGroup(
            id: 'ingredients',
            attributes: <Attribute>[
              Attribute(
                id: 'vegan',
                status: Attribute.STATUS_KNOWN,
                match: 100.0,
              ),
            ],
          ),
        ];

      final ProductPreferencesManager manager = productPreferences
          .getManagerForProduct(beautyProduct);

      expect(
        manager.getImportanceIdForAttributeId('vegan'),
        PreferenceImportance.ID_MANDATORY,
      );

      final MatchedProductV2 matchedProduct = MatchedProductV2(
        beautyProduct,
        manager,
      );
      expect(matchedProduct.status, MatchedProductStatusV2.VERY_GOOD_MATCH);
      expect(
        hasProductMatchingAttributes(beautyProduct, productPreferences),
        isTrue,
      );
    });

    test(
      'hasProductMatchingAttributes returns false when no matching attributes',
      () async {
        final Product beautyProduct = Product(barcode: '222222')
          ..productType = ProductType.beauty
          ..attributeGroups = <AttributeGroup>[
            AttributeGroup(
              id: 'ingredients',
              attributes: <Attribute>[
                Attribute(
                  id: 'vegan',
                  status: Attribute.STATUS_KNOWN,
                  match: 100.0,
                ),
              ],
            ),
          ];

        expect(
          hasProductMatchingAttributes(beautyProduct, productPreferences),
          isFalse,
        );
      },
    );
  });

  group('ProductPageCompatibility', () {
    test('food product computes score and has color', () async {
      await userPreferences.setImportance(
        'nutriscore',
        PreferenceImportance.ID_MANDATORY,
      );

      final Product foodProduct = Product(barcode: '333333')
        ..productType = ProductType.food
        ..attributeGroups = <AttributeGroup>[
          AttributeGroup(
            id: 'nutritional_quality',
            attributes: <Attribute>[
              Attribute(
                id: 'nutriscore',
                status: Attribute.STATUS_KNOWN,
                match: 100.0,
              ),
            ],
          ),
        ];

      final ProductPreferencesManager manager = productPreferences
          .getManagerForProduct(foodProduct);
      final MatchedProductV2 matchedProduct = MatchedProductV2(
        foodProduct,
        manager,
      );

      final ProductPageCompatibility compatibility = ProductPageCompatibility(
        color: Colors.green,
        matchedProductV2: matchedProduct,
        productType: ProductType.food,
      );

      expect(compatibility.score, isNotNull);
      expect(compatibility.color, Colors.green);
    });

    test(
      'beauty product does not compute score but retains color when match is known',
      () async {
        await userPreferences.setImportanceForProject(
          'vegan',
          PreferenceImportance.ID_MANDATORY,
          PreferencesPageProjects.beauty,
        );

        final Product beautyProduct = Product(barcode: '444444')
          ..productType = ProductType.beauty
          ..attributeGroups = <AttributeGroup>[
            AttributeGroup(
              id: 'ingredients',
              attributes: <Attribute>[
                Attribute(
                  id: 'vegan',
                  status: Attribute.STATUS_KNOWN,
                  match: 0.0,
                ),
              ],
            ),
          ];

        final ProductPreferencesManager manager = productPreferences
            .getManagerForProduct(beautyProduct);
        final MatchedProductV2 matchedProduct = MatchedProductV2(
          beautyProduct,
          manager,
        );

        expect(matchedProduct.status, MatchedProductStatusV2.DOES_NOT_MATCH);

        final ProductPageCompatibility compatibility = ProductPageCompatibility(
          color: Colors.red,
          matchedProductV2: matchedProduct,
          productType: ProductType.beauty,
        );

        // Score is null for non-food
        expect(compatibility.score, isNull);
        // But color is shown based on status!
        expect(compatibility.color, Colors.red);
      },
    );

    test('unknown match product has null color', () {
      final Product beautyProduct = Product(barcode: '555555')
        ..productType = ProductType.beauty
        ..attributeGroups = <AttributeGroup>[];

      final ProductPreferencesManager manager = productPreferences
          .getManagerForProduct(beautyProduct);
      final MatchedProductV2 matchedProduct = MatchedProductV2(
        beautyProduct,
        manager,
      );

      expect(matchedProduct.status, MatchedProductStatusV2.UNKNOWN_MATCH);

      final ProductPageCompatibility compatibility = ProductPageCompatibility(
        color: Colors.grey,
        matchedProductV2: matchedProduct,
        productType: ProductType.beauty,
      );

      expect(compatibility.score, isNull);
      expect(compatibility.color, isNull);
    });
  });
}
