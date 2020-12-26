import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smooth_app/pages/alternative_continuous_scan_page.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/contribution_page.dart';
import 'package:smooth_app/pages/continuous_scan_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/tracking_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';
import 'package:smooth_ui_library/navigation/smooth_navigation_layout.dart';

final SentryClient sentry = SentryClient(
    dsn:
        'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745');

// ignore: avoid_void_async
void main() async {
  try {
    runApp(
      MaterialApp(
        //localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        //  S.delegate,
        //  GlobalMaterialLocalizations.delegate,
        //  GlobalWidgetsLocalizations.delegate,
        //  GlobalCupertinoLocalizations.delegate,
        //],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SmoothApp(),
        theme: SmoothThemes.getSmoothThemeData(),
      ),
    );
  } catch (error, stackTrace) {
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
}

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
      color: Colors.white60,
      classicMode: true,
    );
  }

  SmoothNavigationLayoutModel _generateNavigationModel(BuildContext context) {
    return SmoothNavigationLayoutModel(
      screens: <SmoothNavigationScreenModel>[
        _generateChooseScreenModel(context),
        //_generateOrganizationScreenModel(),
        _generateCollaborationScreenModel(context),
        _generateTrackingScreenModel(context),
        _generateProfileScreenModel(context)
      ],
    );
  }

  SmoothNavigationScreenModel _generateChooseScreenModel(BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/ikonate_thin/search.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Choose',
      page: ChoosePage(),
      action: SmoothNavigationActionModel(
        title: AppLocalizations.of(context).scanProductTitle,
        icon: 'assets/actions/scanner_alt_2.svg',
        iconPadding: _navigationIconPadding,
        iconSize: _navigationIconSize,
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

  /*SmoothNavigationScreenModel _generateOrganizationScreenModel() {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/ikonate_thin/organize.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Organize',
      page: OrganizationPage(),
    );
  }*/

  SmoothNavigationScreenModel _generateCollaborationScreenModel(
      BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/ikonate_thin/add.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Contribute',
      page: CollaborationPage(),
      action: SmoothNavigationActionModel(
        title: AppLocalizations.of(context).scanProductTitle,
        icon: 'assets/actions/scanner_alt_2.svg',
        iconPadding: _navigationIconPadding,
        iconSize: _navigationIconSize,
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

  SmoothNavigationScreenModel _generateTrackingScreenModel(
      BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/ikonate_thin/activity.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Track',
      page: TrackingPage(),
      action: SmoothNavigationActionModel(
        title: AppLocalizations.of(context).scanProductTitle,
        icon: 'assets/actions/scanner_alt_2.svg',
        iconPadding: _navigationIconPadding,
        iconSize: _navigationIconSize,
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

  SmoothNavigationScreenModel _generateProfileScreenModel(
      BuildContext context) {
    return SmoothNavigationScreenModel(
      icon: Container(
        padding: EdgeInsets.all(_navigationIconPadding),
        child: SvgPicture.asset(
          'assets/ikonate_thin/person.svg',
          width: _navigationIconSize,
          height: _navigationIconSize,
        ),
      ),
      title: 'Profile',
      page: ProfilePage(),
      action: SmoothNavigationActionModel(
        title: AppLocalizations.of(context).scanProductTitle,
        icon: 'assets/actions/scanner_alt_2.svg',
        iconPadding: _navigationIconPadding,
        iconSize: _navigationIconSize,
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
}
