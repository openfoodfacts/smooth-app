import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class LoggedOutAppBarTitle extends StatelessWidget {
  const LoggedOutAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return FlexibleSpaceBar(
      expandedTitleScale: 1.0,
      title: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          Container(
            width: PROFILE_PICTURE_SIZE,
            height: PROFILE_PICTURE_SIZE,
            padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/app/release_icon_light_transparent_no_border.svg',
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        appLocalizations.logged_out,
                        style: TextStyle(
                          color: themeExtension.secondaryNormal,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
