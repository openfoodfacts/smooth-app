import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Creates a fake entry for the product page (the same as a KP entry).
class ProductPageEntry extends StatelessWidget {
  const ProductPageEntry({
    required this.label,
    required this.leading,
    required this.onTap,
    this.leadingColor,
    this.trailing,
    super.key,
  });

  final VoidCallback onTap;
  final String label;
  final Widget leading;
  final Color? leadingColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SMALL_SPACE,
          vertical: BALANCED_SPACE,
        ),
        child: Row(
          spacing: SMALL_SPACE,
          children: <Widget>[
            CircleAvatar(
              backgroundColor:
                  leadingColor ??
                  (lightTheme ? theme.primaryLight : theme.primaryMedium),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(7.0),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: context.lightTheme()
                        ? theme.primaryUltraBlack
                        : theme.primaryLight,
                  ),
                  child: Center(child: leading),
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ?trailing,
            icons.AppIconTheme(
              color: lightTheme ? theme.greyDark : theme.greyLight,
              size: 15.0,
              child: icons.Chevron.horizontalDirectional(context),
            ),
          ],
        ),
      ),
    );
  }
}
