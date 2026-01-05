import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SearchBarIcon extends StatelessWidget {
  const SearchBarIcon({
    this.icon,
    this.onTap,
    this.label,
    this.padding,
    super.key,
  }) : assert(label == null || onTap != null);

  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final String? label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final Widget widget = AspectRatio(
      aspectRatio: 1.0,
      child: Ink(
        decoration: ShapeDecoration(
          color: context.lightTheme()
              ? theme.primaryBlack
              : theme.primaryUltraBlack,
          shape: const CircleBorder(),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsetsDirectional.all(BALANCED_SPACE),
          child: IconTheme(
            data: const IconThemeData(size: 20.0, color: Colors.white),
            child: icon ?? const icons.Search.off(),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return widget;
    } else {
      return Semantics(
        label: label,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: label ?? '',
          child: InkWell(
            borderRadius: SearchFieldUIHelper.SEARCH_BAR_BORDER_RADIUS,
            onTap: onTap,
            child: widget,
          ),
        ),
      );
    }
  }
}
