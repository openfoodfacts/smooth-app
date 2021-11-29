import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/smooth_bottom_navigation_bar.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final SmoothBottomNavigationTab tabItem;

  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (tabItem == SmoothBottomNavigationTab.Profile) {
      child = const UserPreferencesPage();
    } else if (tabItem == SmoothBottomNavigationTab.History) {
      child = const HistoryPage();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => child);
      },
    );
  }
}
