import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageField,
    required this.title,
    required this.buttonText,
    this.imageUrl,
  });

  factory ProductImageData.from(ProductImage image, String barcode) {
    return ProductImageData(
      imageField: image.field,
      // TODO(VaiTon): i18n
      title: image.imgid ?? '',
      buttonText: image.imgid ?? '',
      imageUrl: ImageHelper.buildUrl(barcode, image),
    );
  }

  final ImageField imageField;
  final String title;
  final String buttonText;
  final String? imageUrl;
}
