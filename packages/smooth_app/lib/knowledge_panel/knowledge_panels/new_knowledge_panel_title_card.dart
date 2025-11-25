import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class NewKnowledgePanelTitleCard extends StatelessWidget {
  const NewKnowledgePanelTitleCard({
    required this.title,
    required this.subtitle,
    required this.iconUrl,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      decoration: BoxDecoration(
        color: lightTheme
            ? themeExtension.primaryMedium
            : themeExtension.primaryDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: VERY_SMALL_SPACE),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            color: lightTheme
                                ? themeExtension.primarySemiDark
                                : themeExtension.primaryMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: LARGE_SPACE),
          if (iconUrl != null && iconUrl!.isNotEmpty)
            SvgPicture.network(iconUrl!, height: 42.0, fit: BoxFit.cover),
        ],
      ),
    );
  }
}
