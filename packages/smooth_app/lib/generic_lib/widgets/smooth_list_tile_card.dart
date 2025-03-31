import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Displays a [ListTile] in a [SmoothCard] wrapped with an [InkWell].
class SmoothListTileCard extends StatelessWidget {
  const SmoothListTileCard({
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.margin,
    this.color,
    super.key,
  });

  /// Displays a [ListTile] inside a [SmoothCard] with a leading [Column]
  /// containing the specified [icon]
  SmoothListTileCard.icon({
    Widget? icon,
    Widget? title,
    Widget? subtitle,
    GestureTapCallback? onTap,
    EdgeInsetsGeometry? margin,
    Color? color,
    Key? key,
  }) : this(
          title: title,
          subtitle: subtitle,
          key: key,
          onTap: onTap,
          color: color,
          // we use a Column to have the icon centered vertically
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[icon ?? const Icon(Icons.edit)],
          ),
          margin: margin,
        );

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      padding: EdgeInsets.zero,
      margin: margin ?? const EdgeInsets.all(VERY_SMALL_SPACE),
      elevation: 4.0,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: onTap,
        child: 
          IntrinsicHeight(
            child: Row(
            children: [
                  Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightTheme
                                        ? extension.primaryBlack
                                        : extension.primarySemiDark,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
                                    child: IconTheme(
                                      data: IconThemeData(
                                        color: extension.primaryLight,
                                        size: 20.0,
                                      ),
                                      child: leading!,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: ListTile(
                        title: title,
                        subtitle: subtitle,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(ConstantIcons.forwardIcon),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }