import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/keywords_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

void main() {
  test('Search results come without knowledge panels', () {
    final AbstractQueryConfiguration configuration = KeywordsProductQuery(
      'chocolate',
      productType: ProductType.food,
      world: true,
    ).getQueryConfiguration();
    final String fields = configuration.getParametersMap()['fields']!;

    expect(fields, isNot(contains('knowledge_panels')));
    expect(fields, contains('attribute_groups'));
    expect(fields, contains('image_front_url'));
  });

  test('The product page still downloads knowledge panels', () {
    expect(ProductQuery.fields, contains(ProductField.KNOWLEDGE_PANELS));
  });
}
