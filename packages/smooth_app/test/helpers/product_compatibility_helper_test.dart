import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';

ProductCompatibilityHelper _helperForCompatibilityScore(
  double compatbilityScore,
) {
  final Product product = Product(
    barcode: 'test-barcode',
    attributeGroups: <AttributeGroup>[
      AttributeGroup(
        attributes: <Attribute>[
          Attribute(id: 'test-attribute', match: compatbilityScore),
        ],
      ),
    ],
  );
  final ProductPreferencesManager preferencesManager =
      ProductPreferencesManager(
        ProductPreferencesSelection(
          getImportance: (_) => PreferenceImportance.ID_IMPORTANT,
        ),
      );

  return ProductCompatibilityHelper.product(
    MatchedProductV2(product, preferencesManager),
  );
}

void main() {
  group('ProductCompatibilityHelper.getFormattedScore', () {
    test('formats a single-digit score without a leading zero by default', () {
      expect(_helperForCompatibilityScore(7).getFormattedScore(), '7');
    });

    test('truncates a fractional single-digit score', () {
      expect(_helperForCompatibilityScore(9.75).getFormattedScore(), '9');
    });

    test('formats zero as a single digit', () {
      expect(_helperForCompatibilityScore(0).getFormattedScore(), '0');
    });

    test('truncates decimal scores to int', () {
      expect(_helperForCompatibilityScore(42.75).getFormattedScore(), '42');
    });
  });
}
