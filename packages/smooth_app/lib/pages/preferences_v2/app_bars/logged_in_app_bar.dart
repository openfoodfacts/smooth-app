import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_background.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_statistics_card.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/search_bottom_bar.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class LoggedInAppBar extends StatelessWidget {
  const LoggedInAppBar({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();

    return SliverAppBar(
      title: Row(
        children: <Widget>[
          Container(
            width: PROFILE_PICTURE_SIZE,
            height: PROFILE_PICTURE_SIZE,
            padding: const EdgeInsetsDirectional.all(8.0),
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
                        style: const TextStyle(
                          color: Colors.white,
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
                          child: AppBarStatisticsCard(
                            imagePath: 'assets/preferences/ingredients.png',
                            description: appLocalizations
                                .preferences_app_bar_products_modified,
                            lazyCounter: const LazyCounterUserSearch(
                              UserSearchType.CONTRIBUTOR,
                            ),
                          ),
                        ),
                        const SizedBox(width: MEDIUM_SPACE),
                        Expanded(
                          child: AppBarStatisticsCard(
                            imagePath: 'assets/preferences/cash.png',
                            description: appLocalizations
                                .preferences_app_bar_prices_added,
                            lazyCounter: LazyCounterPrices(userId),
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
                        decoration: BoxDecoration(
                          borderRadius: ROUNDED_BORDER_RADIUS,
                          color: theme.cardColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              appLocalizations
                                  .preferences_app_bar_see_all_stats,
                              style: TextStyle(
                                color: lightTheme
                                    ? theme.primaryColor
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: MEDIUM_SPACE),
                            Icon(
                              Icons.arrow_circle_right,
                              size: 24.0,
                              color: lightTheme
                                  ? theme.primaryColor
                                  : Colors.white,
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
}
