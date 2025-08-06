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
         margin: margin,
       );

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      padding: EdgeInsets.zero,
      margin: margin ?? const EdgeInsets.all(VERY_SMALL_SPACE),
      elevation: 4.0,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: onTap,
        child: ListTile(
          title: title,
          subtitle: subtitle,
          leading: leading != null
              ? DecoratedBox(
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
                        color: lightTheme ? Colors.white : Colors.white,
                        size: 20.0,
                      ),
                      child: leading!,
                    ),
                  ),
                )
              : null,
          trailing: Icon(ConstantIcons.forwardIcon),
        ),
      ),
    );
  }
}
