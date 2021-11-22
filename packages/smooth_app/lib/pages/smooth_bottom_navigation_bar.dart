import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class _Page {
  const _Page({required this.name, required this.icon, required this.body});
  final String name;
  final IconData icon;
  final Widget body;
}

class SmoothBottomNavigationBar extends StatelessWidget {
  static const List<_Page> _pages = <_Page>[
    _Page(
      name: 'Profile', // TODO(monsieurtanuki): translate
      icon: Icons.account_circle,
      body: UserPreferencesPage(),
    ),
    _Page(
      name: 'Scan or Search',
      icon: Icons.search,
      body: ScanPage(),
    ),
    _Page(
      name: 'History',
      icon: Icons.history,
      body: HistoryPage(),
    ),
  ];

  static Widget getCurrentPage(final BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return _pages[userPreferences.bottomTabIndex].body;
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.white,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      currentIndex: userPreferences.bottomTabIndex,
      onTap: (final int index) async {
        userPreferences.setBottomTabIndex(index);
        await Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => _pages[index].body,
          ),
        );
      },
      items: _pages
          .map(
            (_Page p) => BottomNavigationBarItem(
              icon: Icon(p.icon, size: 28),
              label: p.name,
            ),
          )
          .toList(),
    );
  }
}
