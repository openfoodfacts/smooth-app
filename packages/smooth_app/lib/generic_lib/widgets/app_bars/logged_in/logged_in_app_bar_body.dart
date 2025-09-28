import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/all_statistics_button.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/contribution_statistics_card.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/prices_statistics_card.dart';

/// 2 statistics cards + button to all statistics.
class LoggedInAppBarBody extends StatelessWidget {
  const LoggedInAppBarBody({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Provider<AutoSizeGroup>(
          create: (_) => AutoSizeGroup(),
          child: Row(
            spacing: MEDIUM_SPACE,
            children: <Widget>[
              const Expanded(child: ContributionStatisticsCard()),
              Expanded(child: PricesStatisticsCard(userId: userId)),
            ],
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        const AllStatisticsButton(),
      ],
    );
  }
}
