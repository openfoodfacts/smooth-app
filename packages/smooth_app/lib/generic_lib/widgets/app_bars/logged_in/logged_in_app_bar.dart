import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/all_statistics_button.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar_body.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar_header.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/app_bar_statistics_card.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/profile_app_bar.dart';

class LoggedInAppBar extends StatelessWidget {
  const LoggedInAppBar({required this.userId, super.key})
    : assert(userId.length > 0);

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ProfileAppBar(
      contentHeight:
          AppBarStatisticsCard.HEIGHT +
          MEDIUM_SPACE +
          AllStatisticsButton.MIN_HEIGHT,
      title: LoggedInAppBarHeader(userId: userId),
      content: LoggedInAppBarBody(userId: userId),
    );
  }
}
