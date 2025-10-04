import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/all_statistics_button.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/contribution_statistics_card.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/prices_statistics_card.dart';

class LoggedInAppBarBody extends StatelessWidget {
  const LoggedInAppBarBody({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

    return FlexibleSpaceBar(
      collapseMode: CollapseMode.none,
      background: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: SEARCH_BOTTOM_HEIGHT),
        child: AppBarBackground(
          height: LOGGED_IN_APP_BAR_EXPANDED_HEIGHT,
          child: Container(
            margin: EdgeInsetsDirectional.only(
              top:
                  MediaQuery.paddingOf(context).top +
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
                  spacing: MEDIUM_SPACE,
                  children: <Widget>[
                    Expanded(
                      child: ContributionStatisticsCard(
                        userId: userId,
                        autoSizeGroup: autoSizeGroup,
                      ),
                    ),
                    Expanded(
                      child: PricesStatisticsCard(
                        userId: userId,
                        autoSizeGroup: autoSizeGroup,
                      ),
                    ),
                  ],
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(top: MEDIUM_SPACE),
                    child: AllStatisticsButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
