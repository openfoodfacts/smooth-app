import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';

enum BottomNavigationTab {
  Profile,
  Scan,
  History,
}

/// Here the different tabs in the bottom navigation bar are taken care of,
/// so that they are stateful, that is not only things like the scroll position
/// but also keeping the navigation on the different tabs.
///
/// Scan Page is an exception here as it needs a little more work so that the
/// camera is not kept unnecessarily kept active.
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

  BottomNavigationTab _currentPage = BottomNavigationTab.Scan;
  List<Widget> _tabs = <Widget>[];

  void _selectTab(BottomNavigationTab tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!
          .currentState!
          .popUntil((Route<dynamic> route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = _pageKeys[index];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final InheritedDataManagerState inheritedDataManager =
        InheritedDataManager.of(context);
    if (inheritedDataManager.showSearchCard &&
        _currentPage != BottomNavigationTab.Scan) {
      _currentPage = BottomNavigationTab.Scan;
      _selectTab(_currentPage, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    _tabs = <Widget>[
      _buildOffstageNavigator(BottomNavigationTab.Profile),
      _buildOffstageNavigator(BottomNavigationTab.Scan),
      _buildOffstageNavigator(BottomNavigationTab.History),
    ];

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
        body: Stack(children: _tabs),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            final InheritedDataManagerState inheritedDataManager =
                InheritedDataManager.of(context);
            if (_currentPage == BottomNavigationTab.Scan &&
                _pageKeys[index] == BottomNavigationTab.Scan) {
              if (!inheritedDataManager.showSearchCard) {
                inheritedDataManager.resetShowSearchCard(true);
              }
              _selectTab(_pageKeys[index], index);
            } else {
              if (inheritedDataManager.showSearchCard) {
                inheritedDataManager.resetShowSearchCard(false);
              }
              _selectTab(_pageKeys[index], index);
            }
          },
          currentIndex: _currentPage.index,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: appLocalizations.profile_navbar_label,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: appLocalizations.scan_navbar_label,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: appLocalizations.history_navbar_label,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(BottomNavigationTab tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: Provider<BottomNavigationTab>.value(
        value: _currentPage,
        child: ScreenVisibilityDetector(
          child: TabNavigator(
            navigatorKey: _navigatorKeys[tabItem]!,
            tabItem: tabItem,
          ),
        ),
      ),
    );
  }
}
