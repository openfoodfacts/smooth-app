import 'package:openfoodfacts/model/ProductImage.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageField,
    required this.title,
    required this.buttonText,
    this.imageUrl,
  });

  final ImageField imageField;
  final String title;
  final String buttonText;
  final String? imageUrl;
}
