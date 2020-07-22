import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/pages/alternative_continuous_scan_page.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/collaboration_page.dart';
import 'package:smooth_app/pages/continuous_scan_page.dart';
import 'package:smooth_app/pages/organization_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/tracking_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';
import 'package:smooth_ui_library/navigation/smooth_navigation_layout.dart';

void main() => runApp(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: SmoothApp(),
        theme: SmoothThemes.getSmoothThemeData(),
      ),
    );

class SmoothApp extends StatelessWidget {
  final double _navigationIconSize = 32.0;
  final double _navigationIconPadding = 5.0;

  @override
  Widget build(BuildContext context) {
    return SmoothNavigationLayout(
      layout: _generateNavigationModel(context),
      animationDuration: 300,
      animationCurve: Curves.easeInOutBack,
      borderRadius: 20.0,
      color: Colors.white70,
      classicMode: true,
    );
  }

  SmoothNavigationLayoutModel _generateNavigationModel(BuildContext context) {
    return SmoothNavigationLayoutModel(
      screens: <SmoothNavigationScreenModel>[
        _generateChooseScreenModel(context),
        _generateOrganizationScreenModel(),
        _generateCollaborationScreenModel(),
        _generateTrackingScreenModel(),
        _generateProfileScreenModel(context)
      ],
    );
  }

  SmoothNavigationScreenModel _generateChooseScreenModel(BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/navigation/search.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Choose',
      page: ChoosePage(),
      action: SmoothNavigationActionModel(
        title: S.of(context).scanProductTitle,
        icon: Container(
          padding: EdgeInsets.all(_navigationIconPadding),
          child: SvgPicture.asset(
            'assets/actions/camera.svg',
            width: _navigationIconSize,
            height: _navigationIconSize,
          ),
        ),
        onTap: () async {
          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          final Widget newPage = sharedPreferences.getBool('useMlKit') ?? true
              ? ContinuousScanPage()
              : AlternativeContinuousScanPage();
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
                builder: (BuildContext context) => newPage),
          );
        },
      ),
    );
  }

  SmoothNavigationScreenModel _generateOrganizationScreenModel() {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/navigation/organize.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Organize',
      page: OrganizationPage(),
    );
  }

  SmoothNavigationScreenModel _generateCollaborationScreenModel() {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/navigation/contribute.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Contribute',
      page: CollaborationPage(),
    );
  }

  SmoothNavigationScreenModel _generateTrackingScreenModel() {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/navigation/track.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Track',
      page: TrackingPage(),
    );
  }

  SmoothNavigationScreenModel _generateProfileScreenModel(
      BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/navigation/user.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Profile',
      page: ProfilePage(),
      action: SmoothNavigationActionModel(
        title: S.of(context).preferencesText,
        icon: Container(
          padding: EdgeInsets.all(_navigationIconPadding),
          child: SvgPicture.asset(
            'assets/actions/preferences.svg',
            width: _navigationIconSize,
            height: _navigationIconSize,
          ),
        ),
        onTap: () => showCupertinoModalBottomSheet<Widget>(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          bounce: true,
          barrierColor: Colors.black45,
          builder: (BuildContext context, ScrollController scrollController) =>
              UserPreferencesView(scrollController),
        ),
      ),
    );
  }
}
