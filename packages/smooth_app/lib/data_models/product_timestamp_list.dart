import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_timestamp.dart';

/// List of [ProductTimestamp]s.
class ProductTimestampList implements ProductTimestamp {
  ProductTimestampList(this.list);

  final List<ProductTimestamp> list;

  @override
  Future<int?> getTimestamp(final Product product) async {
    int? maxTimestamp;
    for (final ProductTimestamp productTimestamp in list) {
      final int? tmp = await productTimestamp.getTimestamp(product);
      if (tmp == null) {
        continue;
      }
      if (maxTimestamp == null || maxTimestamp < tmp) {
        maxTimestamp = tmp;
      }
    }
    return maxTimestamp;
  }
}
