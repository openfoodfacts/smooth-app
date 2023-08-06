import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/carousel_manager.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/onboarding/consent_analytics_page.dart';
import 'package:smooth_app/pages/onboarding/permissions_page.dart';
import 'package:smooth_app/pages/onboarding/preferences_page.dart';
import 'package:smooth_app/pages/onboarding/reinvention_page.dart';
import 'package:smooth_app/pages/onboarding/sample_eco_card_page.dart';
import 'package:smooth_app/pages/onboarding/sample_health_card_page.dart';
import 'package:smooth_app/pages/onboarding/scan_example.dart';
import 'package:smooth_app/pages/onboarding/welcome_page.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

enum OnboardingPage {
  NOT_STARTED,
  REINVENTION,
  WELCOME,
  SCAN_EXAMPLE,
  HEALTH_CARD_EXAMPLE,
  ECO_CARD_EXAMPLE,
  PREFERENCES_PAGE,
  PERMISSIONS_PAGE,
  CONSENT_PAGE,
  ONBOARDING_COMPLETE;

  OnboardingPage getPrevPage() {
    int indexOf = OnboardingPage.values.indexOf(this);
    if (indexOf > 0) {
      indexOf--;
    }
    return OnboardingPage.values[indexOf];
  }

  OnboardingPage getNextPage() {
    int indexOf = OnboardingPage.values.indexOf(this);
    if (indexOf < OnboardingPage.values.length - 1) {
      indexOf++;
    }
    return OnboardingPage.values[indexOf];
  }

  bool isOnboardingComplete() =>
      OnboardingPage.values.indexOf(this) == OnboardingPage.values.length - 1;

  bool isOnboardingNotStarted() => OnboardingPage.values.indexOf(this) == 0;

  Color getBackgroundColor() {
    switch (this) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.REINVENTION:
        return const Color(0xFFDFF4FF);
      case OnboardingPage.WELCOME:
        return const Color(0xFFFCFCFC);
      case OnboardingPage.SCAN_EXAMPLE:
        return const Color(0xFFE3F6FF);
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return const Color(0xFFFFF1D1);
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return const Color(0xFFE3F6DE);
      case OnboardingPage.PREFERENCES_PAGE:
        return const Color(0xFFEBF1FF);
      case OnboardingPage.PERMISSIONS_PAGE:
        return const Color(0xFFEBF1FF);
      case OnboardingPage.CONSENT_PAGE:
        return const Color(0xFFFFF2DF);
      case OnboardingPage.ONBOARDING_COMPLETE:
        // whatever, it's not used
        return Colors.black;
    }
  }

  Widget getPageWidget(BuildContext context) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final Color backgroundColor = getBackgroundColor();
    switch (this) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.REINVENTION:
        return ReinventionPage(backgroundColor);
      case OnboardingPage.WELCOME:
        return WelcomePage(backgroundColor);
      case OnboardingPage.SCAN_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          ScanExample(backgroundColor),
        );
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          SampleHealthCardPage(localDatabase, backgroundColor),
        );
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          SampleEcoCardPage(localDatabase, backgroundColor),
        );
      case OnboardingPage.PREFERENCES_PAGE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          PreferencesPage(localDatabase, backgroundColor),
        );
      case OnboardingPage.PERMISSIONS_PAGE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          PermissionsPage(backgroundColor),
        );
      case OnboardingPage.CONSENT_PAGE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          ConsentAnalyticsPage(backgroundColor),
        );
      case OnboardingPage.ONBOARDING_COMPLETE:
        return ExternalCarouselManager(child: PageManager());
    }
  }

  Widget _wrapWidgetInCustomBackNavigator(
    BuildContext context,
    Widget widget,
  ) =>
      WillPopScope(
        onWillPop: () async => false,
        // wrap the widget in [Builder] to allow navigation on the [context].
        child: Builder(
          builder: (BuildContext context) => SmoothScaffold(
            body: widget,
            brightness: Brightness.dark,
          ),
        ),
      );
}

/// Decide which page to take the user to.
class OnboardingFlowNavigator {
  OnboardingFlowNavigator(this._userPreferences) {
    if (_historyOnboardingNav.isEmpty) {
      _historyOnboardingNav.add(_userPreferences.lastVisitedOnboardingPage);
    }
  }

  final UserPreferences _userPreferences;

  //used for recording history of onboarding pages navigated
  static final List<OnboardingPage> _historyOnboardingNav = <OnboardingPage>[];

  Future<void> navigateToPage(BuildContext context, OnboardingPage page) async {
    _userPreferences.setLastVisitedOnboardingPage(page);
    _historyOnboardingNav.add(page);

    final MaterialPageRoute<void> route = MaterialPageRoute<void>(
      builder: (BuildContext context) => page.getPageWidget(context),
    );

    if (page.isOnboardingComplete()) {
      AppNavigator.of(context).pushReplacement(AppRoutes.HOME);
    } else {
      await Navigator.of(context).push<void>(route);
    }
  }

  static bool isOnboardingPagedInHistory(OnboardingPage page) {
    bool exists = false;
    if (_historyOnboardingNav.isNotEmpty) {
      final int indexPage = _historyOnboardingNav.indexOf(page);
      exists = indexPage >= 0 && indexPage < (_historyOnboardingNav.length - 1);
    }
    return exists;
  }
}
