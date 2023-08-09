import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/carousel_manager.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';

enum BottomNavigationTab {
  Profile,
  Scan,
  List,
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
    BottomNavigationTab.List,
  ];

  final Map<BottomNavigationTab, GlobalKey<NavigatorState>> _navigatorKeys =
      <BottomNavigationTab, GlobalKey<NavigatorState>>{
    BottomNavigationTab.Profile: GlobalKey<NavigatorState>(),
    BottomNavigationTab.Scan: GlobalKey<NavigatorState>(),
    BottomNavigationTab.List: GlobalKey<NavigatorState>(),
  };

  BottomNavigationTab _currentPage = BottomNavigationTab.Scan;

  /// To implement a lazy-loading algorithm to only load visible tabs, we
  /// store a list of boolean if a tab have been visible at least one time.
  final List<bool> _loadedTabs = List<bool>.generate(
    BottomNavigationTab.values.length,
    (_) => false,
  );

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
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ExternalCarouselManagerState carouselManager =
        ExternalCarouselManager.watch(context);

    if (carouselManager.forceShowScannerTab) {
      _currentPage = BottomNavigationTab.Scan;
    }

    final List<Widget> tabs = <Widget>[
      _buildOffstageNavigator(BottomNavigationTab.Profile),
      _buildOffstageNavigator(BottomNavigationTab.Scan),
      _buildOffstageNavigator(BottomNavigationTab.List),
    ];

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final bool isProd = userPreferences
            .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
        true;
    final BottomNavigationBar bar = BottomNavigationBar(
      onTap: (int index) {
        if (_currentPage == BottomNavigationTab.Scan &&
            _pageKeys[index] == BottomNavigationTab.Scan) {
          carouselManager.showSearchCard();
        }

        _selectTab(_pageKeys[index], index);
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
          icon: const Icon(Icons.list),
          label: appLocalizations.list_navbar_label,
        ),
      ],
    );
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
        body: Stack(children: tabs),
        bottomNavigationBar: isProd
            ? bar
            : Banner(
                message: 'TEST ENV',
                location: BannerLocation.bottomEnd,
                color: Colors.blue,
                child: bar,
              ),
      ),
    );
  }

  Widget _buildOffstageNavigator(BottomNavigationTab tabItem) {
    final bool offstage = _currentPage != tabItem;
    final int tabPosition = BottomNavigationTab.values.indexOf(tabItem);

    if (offstage && _loadedTabs[tabPosition] == false) {
      return const SizedBox();
    } else if (!offstage) {
      _loadedTabs[tabPosition] = true;
    }

    return Offstage(
      offstage: offstage,
      child: Provider<BottomNavigationTab>.value(
        value: _currentPage,
        child: TabNavigator(
          navigatorKey: _navigatorKeys[tabItem]!,
          tabItem: tabItem,
        ),
      ),
    );
  }
}
