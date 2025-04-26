import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_background.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/search_bottom_bar.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class LoggedInAppBar extends StatelessWidget {
  const LoggedInAppBar({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverAppBar(
      title: Row(
        children: <Widget>[
          Container(
            width: PROFILE_PICTURE_SIZE,
            height: PROFILE_PICTURE_SIZE,
            padding: const EdgeInsetsDirectional.all(8.0),
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
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
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
                const SizedBox(height: 4.0),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        appLocalizations.preferences_app_bar_message,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
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
          padding:
              const EdgeInsetsDirectional.only(bottom: SEARCH_BOTTOM_HEIGHT),
          child: Stack(
            children: <Widget>[
              AppBarBackground(),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        TOOLBAR_HEIGHT +
                        MEDIUM_SPACE),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MEDIUM_SPACE,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildStatisticCard(
                            imagePath: 'assets/preferences/ingredients.png',
                            count: '150+',
                            description: appLocalizations
                                .preferences_app_bar_products_modified,
                            themeExtension: themeExtension,
                          ),
                        ),
                        const SizedBox(width: MEDIUM_SPACE),
                        Expanded(
                          child: _buildStatisticCard(
                            imagePath: 'assets/preferences/cash.png',
                            count: '950+',
                            description: appLocalizations
                                .preferences_app_bar_prices_added,
                            themeExtension: themeExtension,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).push<dynamic>(
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                const UserPreferencesPage(
                              type: PreferencePageType.ACCOUNT,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: MEDIUM_SPACE),
                        padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                        decoration: const BoxDecoration(
                          borderRadius: ROUNDED_BORDER_RADIUS,
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              appLocalizations
                                  .preferences_app_bar_see_all_stats,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: MEDIUM_SPACE),
                            Icon(
                              Icons.arrow_circle_right,
                              size: 24.0,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(SEARCH_BOTTOM_HEIGHT),
        child: SearchBottomBar(),
      ),
      toolbarHeight: TOOLBAR_HEIGHT,
      pinned: true,
      floating: true,
      expandedHeight: 310.0,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: ROUNDED_RADIUS,
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String imagePath,
    required String count,
    required String description,
    required SmoothColorsThemeExtension themeExtension,
  }) {
    return Container(
      height: 68.0,
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        color: themeExtension.secondaryVibrant.withValues(
          alpha: 0.8,
        ),
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 32.0,
          ),
          const SizedBox(width: MEDIUM_SPACE),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        count,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    )
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
