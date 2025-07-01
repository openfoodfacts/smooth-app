import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelScoreCard extends StatelessWidget {
  const KnowledgePanelScoreCard({
    super.key,
    required this.element,
    this.isClickable = true,
  });

  final TitleElement element;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MEDIUM_SPACE,
        vertical: VERY_SMALL_SPACE,
      ),
      child: Row(
        children: <Widget>[
          if (element.iconUrl != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: SvgPicture.network(
                element.iconUrl!,
                height: 32.0,
              ),
            ),
          if (element.iconUrl != null) const SizedBox(width: SMALL_SPACE),
          Expanded(
            child: Text(
              element.subtitle ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isClickable)
            Icon(
              ConstantIcons.forwardIcon,
              color: themeExtension.primaryTone,
              size: 16.0,
            ),
        ],
      ),
    );
  }
}
