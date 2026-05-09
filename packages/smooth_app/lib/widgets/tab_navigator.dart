import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/preferences_v2/preferences_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    required this.navigatorKey,
    required this.tabItem,
    this.visible = true,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavigationTab tabItem;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return EMPTY_WIDGET;
    }

    final Widget child = switch (tabItem) {
      BottomNavigationTab.HomePage => const HomePage(),
      BottomNavigationTab.List => const HistoryPage(),
      BottomNavigationTab.Profile => PreferencesPage(),
      BottomNavigationTab.Scan => const ScanPage(),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic res) async {
        if (didPop) {
          return;
        }

        if (navigatorKey.currentState!.canPop()) {
          navigatorKey.currentState!.pop(res);
        }
      },
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => child,
          );
        },
      ),
    );
  }
}
