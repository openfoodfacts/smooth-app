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

  /// Convert [imageUrl] to specified [size]
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
    final String number = size.toNumber();
    final String extension =
        imageUrl.substring(extensionIndex, imageUrl.length);
    return baseUrl + number + extension;
  }
}
