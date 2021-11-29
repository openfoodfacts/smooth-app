import 'package:flutter/material.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';

enum SmoothBottomNavigationTab {
  Profile,
  Scan,
  History,
}

class SmoothBottomNavigationBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SmoothBottomNavigationBarState();
}

class SmoothBottomNavigationBarState extends State<SmoothBottomNavigationBar> {
  List<SmoothBottomNavigationTab> pageKeys = <SmoothBottomNavigationTab>[
    SmoothBottomNavigationTab.Profile,
    SmoothBottomNavigationTab.Scan,
    SmoothBottomNavigationTab.History,
  ];
  SmoothBottomNavigationTab _currentPage = SmoothBottomNavigationTab.Scan;

  final Map<SmoothBottomNavigationTab, GlobalKey<NavigatorState>>
      _navigatorKeys = <SmoothBottomNavigationTab, GlobalKey<NavigatorState>>{
    SmoothBottomNavigationTab.Profile: GlobalKey<NavigatorState>(),
    SmoothBottomNavigationTab.Scan: GlobalKey<NavigatorState>(),
    SmoothBottomNavigationTab.History: GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 1;

  void _selectTab(SmoothBottomNavigationTab tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!
          .currentState!
          .popUntil((Route<dynamic> route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
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
          if (_currentPage != SmoothBottomNavigationTab.Scan) {
            _selectTab(SmoothBottomNavigationTab.Scan, 1);

            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(SmoothBottomNavigationTab.Profile),
          _buildOffstageNavigator(SmoothBottomNavigationTab.Scan),
          _buildOffstageNavigator(SmoothBottomNavigationTab.History),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
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
          //type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(SmoothBottomNavigationTab tabItem) {
    final bool offstage = _currentPage != tabItem;
    return Offstage(
      //TODO: Replace with offstage
      offstage: tabItem != SmoothBottomNavigationTab.Scan,
      child: tabItem != SmoothBottomNavigationTab.Scan
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
