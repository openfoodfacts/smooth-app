import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/search/search_field.dart';

class SearchBottomBar extends StatefulWidget {
  @override
  State<SearchBottomBar> createState() => _SearchBottomBarState();

  static double get totalHeight =>
      SEARCH_BOTTOM_HEIGHT + AppBarBackground.RADIUS.y;
}

class _SearchBottomBarState extends State<SearchBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: SMALL_SPACE,
        horizontal: MEDIUM_SPACE,
      ),
      child: SearchField(
        searchHelper: context.read<PreferencesRootSearchController>(),
        showNavigationButton: false,
        searchOnChange: true,
      ),
    );
  }
}
