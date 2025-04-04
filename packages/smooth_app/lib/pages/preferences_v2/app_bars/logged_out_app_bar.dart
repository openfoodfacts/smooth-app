import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_background.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/search_bottom_bar.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

const double TOOLBAR_HEIGHT = 92.0;

class LoggedOutAppBar extends StatelessWidget {
  const LoggedOutAppBar();

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
            width: 68.0,
            height: 68.0,
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
                        'Non connecté',
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
                          child: _buildActionCard(
                            title: appLocalizations.create_account,
                            themeExtension: themeExtension,
                          ),
                        ),
                        const SizedBox(width: MEDIUM_SPACE),
                        Expanded(
                          child: _buildActionCard(
                            title: appLocalizations.sign_in,
                            themeExtension: themeExtension,
                          ),
                        ),
                      ],
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
      expandedHeight: 268.0,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: ROUNDED_RADIUS,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required SmoothColorsThemeExtension themeExtension,
  }) {
    return Container(
      height: 78.0,
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      decoration: const BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: themeExtension.primaryBlack,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_circle_right,
                      color: themeExtension.primaryBlack,
                      size: 28.0,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
