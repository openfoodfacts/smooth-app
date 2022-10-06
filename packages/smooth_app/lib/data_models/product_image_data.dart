import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageField,
    required this.title,
    required this.buttonText,
    required this.imageDescriptor,
  });

  final ImageField imageField;
  final String title;
  final String buttonText;
  final ImageDescriptor? imageDescriptor;

  String? getImageUrl(ImageSize size) {
    return imageDescriptor?.createUrlFor(size);
  }
}

class ImageDescriptor {
  const ImageDescriptor._create(this._baseUrl, this._extension);

  final String _baseUrl;
  final String _extension;
  static const String _SEPARATOR = '.';

  static ImageDescriptor? fromUrl(String? imageUrl) {
    if (imageUrl == null) {
      return null;
    }

    final int extensionIndex = imageUrl.lastIndexOf(_SEPARATOR);
    if (extensionIndex < 0) {
      return null;
    }

    final int sizeIndex = imageUrl.lastIndexOf(_SEPARATOR, extensionIndex - 1);
    if (sizeIndex < 0) {
      return null;
    }

    final String baseUrl = imageUrl.substring(0, sizeIndex + 1);
    final String extension =
        imageUrl.substring(extensionIndex, imageUrl.length);
    return ImageDescriptor._create(baseUrl, extension);
  }

  static ImageDescriptor fromImage(String barcode, ProductImage image) {
    final String rootUrl = ImageHelper.getProductImageRootUrl(barcode);
    final String baseUrl =
        '$rootUrl/${image.field.value}_${image.language.code}.${image.rev}.';
    return ImageDescriptor._create(baseUrl, '.jpg');
  }

  String createUrlFor(ImageSize size) {
    final String number = size.toNumber();
    return _baseUrl + number + _extension;
  }
}
