import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar_content.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar_title.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/profile_app_bar.dart';

class LoggedOutAppBar extends StatelessWidget {
  const LoggedOutAppBar();

  @override
  Widget build(BuildContext context) {
    return const ProfileAppBar(
      contentHeight: LoggedOutAppBarContent.MIN_HEIGHT,
      title: LoggedOutAppBarTitle(),
      content: LoggedOutAppBarContent(),
    );
  }
}
