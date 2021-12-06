import 'package:flutter/material.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';

enum BottomNavigationTab {
  Profile,
  Scan,
  History,
}

class PageManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PageManagerState();
}

class PageManagerState extends State<PageManager> {
  static const List<BottomNavigationTab> _pageKeys = <BottomNavigationTab>[
    BottomNavigationTab.Profile,
    BottomNavigationTab.Scan,
    BottomNavigationTab.History,
  ];

  final Map<BottomNavigationTab, GlobalKey<NavigatorState>> _navigatorKeys =
      <BottomNavigationTab, GlobalKey<NavigatorState>>{
    BottomNavigationTab.Profile: GlobalKey<NavigatorState>(),
    BottomNavigationTab.Scan: GlobalKey<NavigatorState>(),
    BottomNavigationTab.History: GlobalKey<NavigatorState>(),
  };

  int _selectedIndex = 1;
  BottomNavigationTab _currentPage = BottomNavigationTab.Scan;

  void _selectTab(BottomNavigationTab tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!
          .currentState!
          .popUntil((Route<dynamic> route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = _pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != BottomNavigationTab.Scan) {
            _selectTab(BottomNavigationTab.Scan, 1);
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(BottomNavigationTab.Profile),
          _buildOffstageNavigator(BottomNavigationTab.Scan),
          _buildOffstageNavigator(BottomNavigationTab.History),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          onTap: (int index) {
            _selectTab(_pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Scan or Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(BottomNavigationTab tabItem) {
    final bool offstage = _currentPage != tabItem;
    // In order for the scanPage be to able to decide whether to activate the camera or not
    // the offstage value has to be passed to it and can because of that not be
    // handled by the TabNavigator
    return Offstage(
      offstage: offstage,
      child: tabItem != BottomNavigationTab.Scan
          ? TabNavigator(
              navigatorKey: _navigatorKeys[tabItem]!,
              tabItem: tabItem,
            )
          : ScanPage(
              offstage: offstage,
              navigatorKey: _navigatorKeys[tabItem]!,
            ),
    );
  }
}
