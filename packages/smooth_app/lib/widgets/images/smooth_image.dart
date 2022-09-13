import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';

/// Container to display a product image on a product card.
///
/// If [imageProvider] is null, [PictureNotFound] is displayed.
class SmoothImage extends StatelessWidget {
  const SmoothImage({
    this.imageProvider,
    this.height,
    this.width,
    this.color,
    this.decoration,
    this.fit,
  });

  final ImageProvider? imageProvider;
  final double? height;
  final double? width;
  final Color? color;
  final Decoration? decoration;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Container(
          decoration: decoration,
          width: width,
          height: height,
          color: color,
          child: imageProvider == null
              ? const PictureNotFound()
              : Image(
                  image: imageProvider!,
                  fit: fit ?? BoxFit.cover,
                  loadingBuilder: _loadingBuilder,
                ),
        ),
      );

  Widget _loadingBuilder(
    BuildContext _,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    if (progress == null) {
      return child;
    }

    final double progressValue =
        progress.cumulativeBytesLoaded / progress.expectedTotalBytes!;

    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: const AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
        value: progressValue,
      ),
    );
  }
}
