import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_navigation_bar.dart';
import 'package:smooth_app/widgets/tab_navigator.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

enum BottomNavigationTab { Profile, Scan, List }

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

  static final Map<BottomNavigationTab, GlobalKey<NavigatorState>>
  _navigatorKeys = <BottomNavigationTab, GlobalKey<NavigatorState>>{
    BottomNavigationTab.Profile: GlobalKey<NavigatorState>(),
    BottomNavigationTab.Scan: GlobalKey<NavigatorState>(),
    BottomNavigationTab.List: GlobalKey<NavigatorState>(),
  };

  BottomNavigationTab _currentPage = BottomNavigationTab.Scan;

  static final List<Widget> tabs = <Widget>[
    TabNavigator(
      navigatorKey: _navigatorKeys[BottomNavigationTab.Profile]!,
      tabItem: BottomNavigationTab.Profile,
    ),
    TabNavigator(
      navigatorKey: _navigatorKeys[BottomNavigationTab.Scan]!,
      tabItem: BottomNavigationTab.Scan,
    ),
    TabNavigator(
      navigatorKey: _navigatorKeys[BottomNavigationTab.List]!,
      tabItem: BottomNavigationTab.List,
    ),
  ];

  void _selectTab(BottomNavigationTab tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil(
        (Route<dynamic> route) => route.isFirst,
      );
    } else {
      setState(() {
        _currentPage = _pageKeys[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ExternalScanCarouselManagerState carouselManager =
        ExternalScanCarouselManager.watch(context);

    if (carouselManager.forceShowScannerTab) {
      _currentPage = BottomNavigationTab.Scan;
    }

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final bool isProd =
        userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagProd,
        ) ??
        true;
    final Widget bar = DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
            offset: Offset.zero,
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: icons.AppIconTheme(
        size: 20.0,
        child: SmoothNavigationBar(
          destinations: <SmoothNavigationDestination>[
            SmoothNavigationDestination(
              icon: const icons.Profile(),
              label: appLocalizations.profile_navbar_label,
            ),
            SmoothNavigationDestination(
              icon: const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 1.0),
                child: icons.Search.offRounded(),
              ),
              label: appLocalizations.scan_navbar_label,
            ),
            SmoothNavigationDestination(
              icon: const icons.Lists(),
              label: appLocalizations.list_navbar_label,
            ),
          ],
          selectedIndex: _currentPage.index,
          onDestinationSelected: (int index) {
            if (_currentPage == BottomNavigationTab.Scan &&
                _pageKeys[index] == BottomNavigationTab.Scan) {
              carouselManager.showSearchCard();
            }

            _selectTab(_pageKeys[index], index);
          },
        ),
      ),
    );
    return WillPopScope2(
      onWillPop: () async {
        final bool isFirstRouteInCurrentTab = !_navigatorKeys[_currentPage]!
            .currentState!
            .canPop();

        if (isFirstRouteInCurrentTab) {
          if (_currentPage != BottomNavigationTab.Scan) {
            _selectTab(BottomNavigationTab.Scan, 1);
            return (false, null);
          } else {
            /// Exit the app
            return (true, null);
          }
        }

        // let system handle back button if we're on the first route
        return (false, null);
      },
      child: Scaffold(
        body: Provider<BottomNavigationTab>.value(
          value: _currentPage,
          child: IndexedStack(index: _currentPage.index, children: tabs),
        ),
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
}
