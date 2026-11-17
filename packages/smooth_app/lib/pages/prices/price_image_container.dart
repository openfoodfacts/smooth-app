import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class PriceImageContainer extends StatelessWidget {
  const PriceImageContainer({
    required this.size,
    this.imageProvider,
    this.placeholder,
    this.borderRadius,
    this.count,
    super.key,
  });

  final ImageProvider? imageProvider;
  final Widget? placeholder;
  final int? count;
  final BorderRadius? borderRadius;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? ANGULAR_BORDER_RADIUS;

    return SizedBox.fromSize(
      size: size,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: count != null
                ? PriceCountWidget.getForegroundColor(count!)
                : Colors.black54,
          ),
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              if (imageProvider != null)
                ProductPicture.fromImageProvider(
                  imageProvider: imageProvider!,
                  size: size,
                  borderRadius: effectiveBorderRadius,
                )
              else if (placeholder != null)
                Center(child: placeholder)
              else
                PictureNotFound.ink(
                  backgroundDecoration: BoxDecoration(
                    borderRadius: effectiveBorderRadius,
                  ),
                ),
              if (count != null)
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: _PriceCountBadge(
                    count: count!,
                    bottomBorderRadius: Radius.circular(
                      effectiveBorderRadius.bottomLeft.x,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCountBadge extends StatelessWidget {
  const _PriceCountBadge({
    required this.count,
    this.bottomBorderRadius = Radius.zero,
  }) : assert(count >= 0);

  final int count;
  final Radius bottomBorderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PriceCountWidget.getForegroundColor(
          count,
        ).withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12.0),
          topRight: const Radius.circular(12.0),
          bottomLeft: bottomBorderRadius,
          bottomRight: bottomBorderRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: VERY_SMALL_SPACE,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SMALL_SPACE,
          children: <Widget>[
            const icons.PriceTag(color: Colors.white, size: 16.0),
            Text(
              count.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
