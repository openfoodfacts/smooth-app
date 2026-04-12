import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Shared card container for top-list items in the Prices experience.
class PriceTopListCard extends StatelessWidget {
  const PriceTopListCard({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      padding: EdgeInsets.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        onTap: onTap,
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: child,
        ),
      ),
    );
  }
}
