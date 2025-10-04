import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class AppBarStatisticsCard extends StatelessWidget {
  AppBarStatisticsCard({
    required this.imagePath,
    required this.description,
    required this.lazyCounter,
    required this.onTap,
    this.autoSizeGroup,
    super.key,
  }) : assert(imagePath.isNotEmpty, 'imagePath must not be empty.'),
       assert(description.isNotEmpty, 'description must not be empty.');

  final String imagePath;
  final String description;
  final LazyCounter lazyCounter;
  final VoidCallback onTap;
  final AutoSizeGroup? autoSizeGroup;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final int? count = lazyCounter.getLocalCount(userPreferences);

    return InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: onTap,
      child: SizedBox(
        height: STATISTICS_CARD_HEIGHT,
        child: Material(
          borderRadius: ROUNDED_BORDER_RADIUS,
          color: themeExtension.secondaryVibrant.withValues(alpha: 0.8),
          child: Row(
            children: <Widget>[
              const SizedBox(width: MEDIUM_SPACE),
              SvgPicture.asset(imagePath, height: 32.0),
              const SizedBox(width: MEDIUM_SPACE),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            count != null ? count.toString() : '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const icons.Chevron.right(
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AutoSizeText(
                            description,
                            group: autoSizeGroup,
                            minFontSize: 8.0,
                            softWrap: false,
                            maxLines: 1,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: MEDIUM_SPACE),
            ],
          ),
        ),
      ),
    );
  }
}
