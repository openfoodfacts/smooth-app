import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  const TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (tabItem == 'Page1') {
      child = const UserPreferencesPage();
    } else if (tabItem == 'Page2') {
      child = const ScanPage();
    } else if (tabItem == 'Page3') {
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
