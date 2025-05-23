import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_element.dart';

class ProductRawDataCategory {
  const ProductRawDataCategory(this.category, this.rawDatas);

  final ProductRawDataCategories category;
  final List<ProductRawDataElement> rawDatas;
}

enum ProductRawDataCategories {
  labels,
  category,
  ingredients,
  nutriment,
  packaging,
  stores,
  countries
}
