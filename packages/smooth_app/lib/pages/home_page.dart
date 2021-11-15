import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Page {
  const _Page({required this.name, required this.icon, required this.body});
  final String name;
  final IconData icon;
  final Widget body;
}

class _HomePageState extends State<HomePage> {
  static const List<_Page> _pages = <_Page>[
    _Page(
      name: 'Profile',
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
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage].body,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        currentIndex: _currentPage,
        onTap: _onTap,
        items: _pages
            .map((_Page p) => BottomNavigationBarItem(
                  icon: Icon(p.icon, size: 28),
                  label: p.name,
                ))
            .toList(),
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentPage = index;
    });
  }
}
