import 'package:flutter/widgets.dart';
import 'package:smooth_app/data_models/product_image_data.dart';

/// Base class for classes that display a collection of images.
abstract class SmoothImagesView extends StatelessWidget {
  const SmoothImagesView({
    required this.imagesData,
    this.onTap,
    this.loading = false,
  });

  final Map<ProductImageData, ImageProvider?> imagesData;
  final void Function(ProductImageData, ImageProvider?)? onTap;
  final bool loading;
}
