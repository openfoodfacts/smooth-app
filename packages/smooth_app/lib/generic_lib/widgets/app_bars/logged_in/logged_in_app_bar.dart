import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar_body.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar_header.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/search_bottom_bar.dart';

class LoggedInAppBar extends StatelessWidget {
  LoggedInAppBar({required this.userId, super.key}) : assert(userId.isNotEmpty);
  final String userId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SliverAppBar(
      title: LoggedInAppBarHeader(userId: userId),
      flexibleSpace: LoggedInAppBarBody(userId: userId),
      bottom: SearchBottomBar(),
      toolbarHeight: TOOLBAR_HEIGHT,
      pinned: true,
      floating: true,
      expandedHeight: LOGGED_IN_APP_BAR_EXPANDED_HEIGHT,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: ROUNDED_RADIUS),
      ),
      elevation: 12.0,
      forceElevated: true,
    );
  }
}
