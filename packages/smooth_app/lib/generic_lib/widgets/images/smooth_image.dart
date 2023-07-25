import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    this.heroTag,
  });

  final ImageProvider? imageProvider;
  final double? height;
  final double? width;
  final Color? color;
  final Decoration? decoration;
  final BoxFit? fit;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget child = imageProvider == null
        ? const PictureNotFound()
        : Image(
            image: imageProvider!,
            fit: fit ?? BoxFit.cover,
            loadingBuilder: _loadingBuilder,
            errorBuilder: _errorBuilder,
          );

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    return ClipRRect(
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: Container(
        decoration: decoration,
        width: width,
        height: height,
        color: color,
        child: child,
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    final double? progressValue;

    if (progress != null) {
      progressValue =
          progress.cumulativeBytesLoaded / progress.expectedTotalBytes!;
    } else {
      progressValue = null;
    }

    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.primaryColor.withOpacity(0.1),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: theme.brightness == Brightness.dark
              ? const AlwaysStoppedAnimation<Color>(Colors.white)
              : null,
          value: progressValue,
        ),
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object _,
    StackTrace? __,
  ) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.all(MEDIUM_SPACE),
      child: Center(
        child: SvgPicture.asset('assets/misc/error.svg'),
      ),
    );
  }
}
