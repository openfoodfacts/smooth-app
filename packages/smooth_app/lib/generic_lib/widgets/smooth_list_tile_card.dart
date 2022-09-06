import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Displays a [ListTile] in a [SmoothCard] wrapped with an [InkWell].
class SmoothListTileCard extends StatelessWidget {
  const SmoothListTileCard({
    required this.title,
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
          leading: SmoothImage(
            width: VERY_LARGE_SPACE * 5,
            height: MEDIUM_SPACE * 5,
            imageProvider: imageProvider,
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
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: GREY_COLOR,
                      borderRadius: CIRCULAR_BORDER_RADIUS,
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: Shimmer.fromColors(
            baseColor: GREY_COLOR,
            highlightColor: WHITE_COLOR,
            child: const SmoothImage(
              width: VERY_LARGE_SPACE * 5,
              height: MEDIUM_SPACE * 5,
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
            padding: const EdgeInsets.all(VERY_SMALL_SPACE),
            child: ListTile(
              title: title,
              subtitle: subtitle,
              leading: leading,
              trailing: Icon(ConstantIcons.instance.getForwardIcon()),
            ),
          ),
        ),
      );
}
