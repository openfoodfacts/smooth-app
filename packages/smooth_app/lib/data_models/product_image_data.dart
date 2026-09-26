import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageId,
    required this.imageField,
    required this.imageUrl,
    required this.language,
  });

  final String? imageId;
  final ImageField imageField;
  final String? imageUrl;
  final OpenFoodFactsLanguage? language;

  /// Try to convert [imageUrl] to specified [size].
  /// Note that url for specified [size] might not exist on API.
  String? getImageUrl(ImageSize size) {
    final String? imageUrl = this.imageUrl;
    if (imageUrl == null) {
      return null;
    }

    const String SEPARATOR = '.';

    final int extensionIndex = imageUrl.lastIndexOf(SEPARATOR);
    if (extensionIndex < 0) {
      return null;
    }

    final int sizeIndex = imageUrl.lastIndexOf(SEPARATOR, extensionIndex - 1);
    if (sizeIndex < 0) {
      return null;
    }

    final String baseUrl = imageUrl.substring(0, sizeIndex + 1);
    final String number = size.number;
    final String extension = imageUrl.substring(
      extensionIndex,
      imageUrl.length,
    );
    return baseUrl + number + extension;
  }
}
