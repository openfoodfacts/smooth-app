import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class _Page {
  const _Page({required this.name, required this.icon, required this.body});
  final String name;
  final IconData icon;
  final Widget body;
}

enum SmoothBottomNavigationTab {
  Profile,
  Scan,
  History,
}

class SmoothBottomNavigationBar extends StatelessWidget {
  const SmoothBottomNavigationBar({
    this.tab = _defaultTab,
  });

  final SmoothBottomNavigationTab tab;

  static const SmoothBottomNavigationTab _defaultTab =
      SmoothBottomNavigationTab.Scan;

  static const List<SmoothBottomNavigationTab> _tabs =
      <SmoothBottomNavigationTab>[
    SmoothBottomNavigationTab.Profile,
    SmoothBottomNavigationTab.Scan,
    SmoothBottomNavigationTab.History,
  ];

  static const Map<SmoothBottomNavigationTab, _Page> _pages =
      <SmoothBottomNavigationTab, _Page>{
    SmoothBottomNavigationTab.Profile: _Page(
      name: 'Profile', // TODO(monsieurtanuki): translate
      icon: Icons.account_circle,
      body: UserPreferencesPage(),
    ),
    SmoothBottomNavigationTab.Scan: _Page(
      name: 'Scan or Search',
      icon: Icons.search,
      body: ScanPage(),
    ),
    SmoothBottomNavigationTab.History: _Page(
      name: 'History',
      icon: Icons.history,
      body: HistoryPage(),
    ),
  };

  static Widget getDefaultPage() => _getTabPage(_defaultTab);

  static Widget _getTabPage(final SmoothBottomNavigationTab tab) =>
      _pages[tab]!.body;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        currentIndex: _tabs.indexOf(tab),
        onTap: (final int index) async => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => _getTabPage(_tabs[index]),
          ),
        ),
        items: <BottomNavigationBarItem>[
          _buildItem(_pages[_tabs[0]]!),
          _buildItem(_pages[_tabs[1]]!),
          _buildItem(_pages[_tabs[2]]!),
        ],
      );

  BottomNavigationBarItem _buildItem(final _Page page) =>
      BottomNavigationBarItem(
        icon: Icon(page.icon, size: 28),
        label: page.name,
      );
}
