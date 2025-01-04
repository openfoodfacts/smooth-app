import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';

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
    this.fit = BoxFit.cover,
    this.rounded = true,
    this.heroTag,
    this.cacheWidth,
    this.cacheHeight,
  })  : assert(
          cacheWidth == null || imageProvider is NetworkImage,
          'cacheWidth requires a NetworkImage',
        ),
        assert(
          cacheHeight == null || imageProvider is NetworkImage,
          'cacheHeight requires a NetworkImage',
        );

  final ImageProvider? imageProvider;
  final double? height;
  final double? width;
  final Color? color;
  final Decoration? decoration;
  final BoxFit fit;
  final String? heroTag;
  final bool rounded;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    Widget child = switch (imageProvider) {
      NetworkImage(url: final String url) => Image.network(
          url,
          fit: fit,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
          frameBuilder: (_, Widget child, int? frame, ____) {
            if (frame == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return child;
          },
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        ),
      ImageProvider<Object>() => Image(
          image: imageProvider!,
          fit: fit,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
      _ => const PictureNotFound(),
    };

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    child = Container(
        decoration: decoration,
        width: width,
        height: height,
        color: color,
        child: child);

    if (rounded) {
      child = ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: child,
      );
    }

    return child;
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: AnimatedCrossFade(
        crossFadeState: progress == null
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: SmoothAnimationsDuration.long,
        firstChild: child,
        secondChild: Container(
          color: theme.primaryColor.withValues(alpha: 0.1),
          alignment: AlignmentDirectional.center,
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: const SmoothAnimatedLogo(),
        ),
        layoutBuilder: (
          Widget topChild,
          Key topChildKey,
          Widget bottomChild,
          Key bottomChildKey,
        ) {
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Positioned.fill(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object _,
    StackTrace? __,
  ) {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.grey.withValues(alpha: 0.7),
          BlendMode.srcIn,
        ),
        child: const SmoothAppLogo(),
      ),
    );
  }
}
