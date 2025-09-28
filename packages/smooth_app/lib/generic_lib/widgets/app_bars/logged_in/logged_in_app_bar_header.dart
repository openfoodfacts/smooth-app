import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/account_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class LoggedInAppBarHeader extends StatelessWidget {
  const LoggedInAppBarHeader({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PROFILE_PICTURE_SIZE),
      child: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          const UserProfilePicture(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                Text(
                  userId,
                  style: TextStyle(
                    color: themeExtension.secondaryNormal,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  appLocalizations.preferences_app_bar_message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: appLocalizations.preferences_manage_account_tooltip,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsetsDirectional.only(start: 1.5),
              ),
              backgroundColor: WidgetStateProperty.all(Colors.white),
            ),
            icon: icons.User.edit(
              color: themeExtension.primaryUltraBlack,
              size: 19.0,
            ),
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
        ],
      ),
    );
  }
}

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture();

  @override
  Widget build(BuildContext context) {
    final bool lightTheme = context.lightTheme();

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: PROFILE_PICTURE_SIZE,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightTheme ? Colors.white : Colors.black54,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
            child: Center(
              child: SvgPicture.asset(
                lightTheme
                    ? 'assets/app/release_icon_light_transparent_no_border.svg'
                    : 'assets/app/release_icon_dark_transparent_no_border.svg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
