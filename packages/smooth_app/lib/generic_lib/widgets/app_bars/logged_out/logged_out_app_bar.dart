import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar_content.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar_title.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/search_bottom_bar.dart';

class LoggedOutAppBar extends StatelessWidget {
  const LoggedOutAppBar();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SliverAppBar(
      title: const LoggedOutAppBarTitle(),
      flexibleSpace: const LoggedOutAppBarContent(),
      bottom: SearchBottomBar(),
      toolbarHeight: TOOLBAR_HEIGHT,
      pinned: true,
      floating: true,
      expandedHeight: LOGGED_OUT_APP_BAR_EXPANDED_HEIGHT,
      backgroundColor: theme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: ROUNDED_RADIUS),
      ),
      elevation: 8.0,
      shadowColor: Colors.black54,
    );
  }
}
