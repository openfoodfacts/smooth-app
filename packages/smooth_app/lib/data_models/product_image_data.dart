import 'package:openfoodfacts/model/ProductImage.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageField,
    this.imageUrl,
    this.title,
    required this.buttonText,
  });

  final ImageField imageField;
  final String? imageUrl;
  final String? title;
  final String buttonText;
}
