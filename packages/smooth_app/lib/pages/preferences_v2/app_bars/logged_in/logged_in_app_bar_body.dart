import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_background.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/logged_in/app_bar_statistics_card.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class LoggedInAppBarBody extends StatelessWidget {
  const LoggedInAppBarBody({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();

    return FlexibleSpaceBar(
      collapseMode: CollapseMode.none,
      background: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: SEARCH_BOTTOM_HEIGHT,
        ),
        child: Stack(
          children: <Widget>[
            AppBarBackground(),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
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
                          description:
                              appLocalizations.preferences_app_bar_prices_added,
                          lazyCounter: LazyCounterPrices(userId),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: MEDIUM_SPACE,
                    ),
                    child: InkWell(
                      borderRadius: ROUNDED_BORDER_RADIUS,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
