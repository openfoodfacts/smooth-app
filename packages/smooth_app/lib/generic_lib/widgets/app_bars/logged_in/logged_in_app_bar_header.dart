import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/account_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class LoggedInAppBarHeader extends StatelessWidget {
  const LoggedInAppBarHeader({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return FlexibleSpaceBar(
      expandedTitleScale: 1.0,
      title: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          Container(
            width: PROFILE_PICTURE_SIZE,
            height: PROFILE_PICTURE_SIZE,
            padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.cardColor,
            ),
            child: Center(
              child: SvgPicture.asset(
                lightTheme
                    ? 'assets/app/release_icon_light_transparent_no_border.svg'
                    : 'assets/app/release_icon_dark_transparent_no_border.svg',
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        userId,
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
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        appLocalizations.preferences_app_bar_message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.settings, color: theme.primaryColor),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider<PreferencesRootSearchController>(
                          create: (_) => PreferencesRootSearchController(),
                          child: AccountRoot(
                            title: appLocalizations.preferences_account_title,
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
