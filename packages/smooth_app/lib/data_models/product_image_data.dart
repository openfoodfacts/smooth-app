import 'package:collection/collection.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImageData {
  const ProductImageData({
    required this.imageField,
    required this.title,
    required this.buttonText,
    required this.imageSizeToUrlMap,
  });

  ProductImageData.from({
    required this.imageField,
    required this.title,
    required this.buttonText,
    required String? barcode,
    required Iterable<ProductImage> productImages,
  }) : imageSizeToUrlMap = _mapProductImages(barcode, productImages);

  final ImageField imageField;
  final String title;
  final String buttonText;
  final Map<ImageSize?, String> imageSizeToUrlMap;

  static Map<ImageSize?, String> _mapProductImages(
      String? barcode, Iterable<ProductImage> images) {
    final Map<ImageSize?, String?> map = images
        .groupListsBy((ProductImage element) => element.size)
        .map((ImageSize? size, List<ProductImage> images) =>
            MapEntry<ImageSize?, ProductImage>(size, images.first))
        .map((ImageSize? size, ProductImage image) {
      final String? url = image.url ?? ImageHelper.buildUrl(barcode, image);
      return MapEntry<ImageSize?, String?>(size, url);
    });
    map.removeWhere((_, String? image) => image == null);
    return map.cast();
  }

  String? getImageUrl(ImageSize preferredSize) {
    return imageSizeToUrlMap[preferredSize] ??
        imageSizeToUrlMap.values.firstOrNull;
  }
}
