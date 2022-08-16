import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image_container.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class SmoothListTileCard extends StatelessWidget {
  const SmoothListTileCard({
    required final this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    Key? key,
  }) : super(key: key);

  /// Displays a [ListTile] inside a [SmoothCard] with a leading [Column]
  /// containing the specified [imageProvider]
  SmoothListTileCard.image({
    required ImageProvider? imageProvider,
    Widget? title,
    GestureTapCallback? onTap,
  }) : this(
          title: title,
          onTap: onTap,
          leading: SmoothProductImageContainer(
            width: 100,
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                : const PictureNotFound(),
          ),
        );

  /// Displays a [ListTile] inside a [SmoothCard] with a leading [Column]
  /// containing the specified [icon]
  SmoothListTileCard.icon({
    Widget? icon,
    Widget? title,
    Widget? subtitle,
    GestureTapCallback? onTap,
    Key? key,
  }) : this(
          title: title,
          subtitle: subtitle,
          key: key,
          onTap: onTap,
          // we use a Column to have the icon centered vertically
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[icon ?? const Icon(Icons.edit)],
          ),
        );

  /// Displays a loading card with a shimmering effect
  SmoothListTileCard.loading()
      : this(
          title: Shimmer.fromColors(
            baseColor: GREY_COLOR,
            highlightColor: WHITE_COLOR,
            child: Container(
                width: 200,
                height: 10,
                decoration: const BoxDecoration(
                  color: GREY_COLOR,
                  borderRadius: CIRCULAR_BORDER_RADIUS,
                )),
          ),
          leading: Shimmer.fromColors(
            baseColor: GREY_COLOR,
            highlightColor: WHITE_COLOR,
            child: const SmoothProductImageContainer(
              width: 100,
              height: 50,
              color: GREY_COLOR,
            ),
          ),
        );

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) => SmoothCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListTile(
              onTap: onTap,
              title: title,
              subtitle: subtitle,
              leading: leading,
              trailing: Icon(ConstantIcons.instance.getForwardIcon()),
            ),
          ),
        ),
      );
}
