import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/app_bar_authentication_button.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/search_bottom_bar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class LoggedOutAppBar extends StatelessWidget {
  const LoggedOutAppBar();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverAppBar(
      title: Row(
        children: <Widget>[
          Container(
            width: PROFILE_PICTURE_SIZE,
            height: PROFILE_PICTURE_SIZE,
            padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
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
          const SizedBox(width: MEDIUM_SPACE),
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
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.none,
        background: Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: SEARCH_BOTTOM_HEIGHT,
          ),
          child: AppBarBackground(
            height: LOGGED_OUT_APP_BAR_EXPANDED_HEIGHT,
            child: Container(
              margin: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    TOOLBAR_HEIGHT +
                    MEDIUM_SPACE,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MEDIUM_SPACE,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AppBarAuthenticationButton(
                          title: appLocalizations.create_account,
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push<dynamic>(
                              MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    const SignUpPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: MEDIUM_SPACE),
                      Expanded(
                        child: AppBarAuthenticationButton(
                          title: appLocalizations.sign_in,
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push<dynamic>(
                              MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: SearchBottomBar(),
      toolbarHeight: TOOLBAR_HEIGHT,
      pinned: true,
      floating: true,
      expandedHeight: LOGGED_OUT_APP_BAR_EXPANDED_HEIGHT,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: ROUNDED_RADIUS),
      ),
    );
  }
}
