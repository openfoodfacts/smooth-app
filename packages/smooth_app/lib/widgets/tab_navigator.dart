import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavigationTab tabItem;

  @override
  Widget build(BuildContext context) {
    late final Widget child;

    //Scan is not dealt with here, as it has to be handled differently with its greater complexity (camera on/off)
    if (tabItem == BottomNavigationTab.Profile) {
      child = const UserPreferencesPage();
    } else if (tabItem == BottomNavigationTab.History) {
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
