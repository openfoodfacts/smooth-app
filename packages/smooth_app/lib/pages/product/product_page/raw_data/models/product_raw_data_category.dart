import 'package:smooth_app/pages/product/product_page/raw_data/models/raw_data_element.dart';

class ProductRawDataCategory {
  const ProductRawDataCategory(this.category, this.rawDatas);

  final ProductRawDataCategories category;
  final List<ProductRawDataSubCategory> rawDatas;
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
