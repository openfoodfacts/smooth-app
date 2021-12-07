import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    required this.navigatorKey,
    required this.tabItem,
    required this.offstage,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavigationTab tabItem;
  final bool offstage;

  @override
  Widget build(BuildContext context) {
    late final Widget child;

    if (tabItem == BottomNavigationTab.Profile) {
      child = const UserPreferencesPage();
    } else if (tabItem == BottomNavigationTab.History) {
      child = const HistoryPage();
    } else if (tabItem == BottomNavigationTab.Scan) {
      // The ScanPage has it's own Navigator for it to be able to track further navigation
      return ScanPage(offstage: offstage, navigatorKey: navigatorKey);
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
