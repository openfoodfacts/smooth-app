import 'package:flutter/material.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';

enum SmoothBottomNavigationTab {
  Profile,
  Scan,
  History,
};

class SmoothBottomNavigationBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SmoothBottomNavigationBarState();
}

class SmoothBottomNavigationBarState extends State<SmoothBottomNavigationBar> {
  String _currentPage = 'Page1';
  List<String> pageKeys = <String>['Page1', 'Page2', 'Page3'];

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys =
      <String, GlobalKey<NavigatorState>>{
    'Page1': GlobalKey<NavigatorState>(),
    'Page2': GlobalKey<NavigatorState>(),
    'Page3': GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
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
          if (_currentPage != 'Page1') {
            _selectTab('Page1', 1);

            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator('Page1'),
          _buildOffstageNavigator('Page2'),
          _buildOffstageNavigator('Page3'),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_one),
              label: 'Page1',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_two),
              label: 'Page2',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.looks_3),
              label: 'Page3',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
