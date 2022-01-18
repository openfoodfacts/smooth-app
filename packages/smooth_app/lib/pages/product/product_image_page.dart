import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_app/smooth_ui_library/widgets/smooth_gauge.dart';

class ProductImagePage extends StatelessWidget {
  const ProductImagePage({
    required this.product,
    required this.imageField,
    required this.imageProvider,
    required this.title,
    required this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final ImageProvider imageProvider;
  final String title;
  final String buttonText;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PhotoView(
          loadingBuilder:
              (final BuildContext context, final ImageChunkEvent? event) =>
                  Center(
            child: SmoothGauge(
              color: Theme.of(context).colorScheme.onBackground,
              value: event == null ||
                      event.expectedTotalBytes == null ||
                      event.expectedTotalBytes == 0
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale
              .contained, // Makes it easy to dezoom until the photo is contained in the screen
        ),
      );
}
