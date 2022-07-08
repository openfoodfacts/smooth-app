import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/onboarding/consent_analytics_page.dart';
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
  CONSENT_PAGE,
  ONBOARDING_COMPLETE,
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

  static OnboardingPage getNextPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
        return OnboardingPage.REINVENTION;
      case OnboardingPage.REINVENTION:
        return OnboardingPage.WELCOME;
      case OnboardingPage.WELCOME:
        return OnboardingPage.SCAN_EXAMPLE;
      case OnboardingPage.SCAN_EXAMPLE:
        return OnboardingPage.HEALTH_CARD_EXAMPLE;
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return OnboardingPage.ECO_CARD_EXAMPLE;
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return OnboardingPage.PREFERENCES_PAGE;
      case OnboardingPage.PREFERENCES_PAGE:
        return OnboardingPage.CONSENT_PAGE;
      case OnboardingPage.CONSENT_PAGE:
        return OnboardingPage.ONBOARDING_COMPLETE;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return OnboardingPage.ONBOARDING_COMPLETE;
    }
  }

  static OnboardingPage getPrevPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.REINVENTION:
        return OnboardingPage.NOT_STARTED;
      case OnboardingPage.WELCOME:
        return OnboardingPage.REINVENTION;
      case OnboardingPage.SCAN_EXAMPLE:
        return OnboardingPage.WELCOME;
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return OnboardingPage.SCAN_EXAMPLE;
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return OnboardingPage.HEALTH_CARD_EXAMPLE;
      case OnboardingPage.PREFERENCES_PAGE:
        return OnboardingPage.ECO_CARD_EXAMPLE;
      case OnboardingPage.CONSENT_PAGE:
        return OnboardingPage.PREFERENCES_PAGE;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return OnboardingPage.CONSENT_PAGE;
    }
  }

  static bool isOnboardingComplete(final OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.REINVENTION:
      case OnboardingPage.WELCOME:
      case OnboardingPage.SCAN_EXAMPLE:
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
      case OnboardingPage.ECO_CARD_EXAMPLE:
      case OnboardingPage.PREFERENCES_PAGE:
      case OnboardingPage.CONSENT_PAGE:
        return false;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return true;
    }
  }

  void navigateToPage(BuildContext context, OnboardingPage page) {
    _userPreferences.setLastVisitedOnboardingPage(page);
    _historyOnboardingNav.add(page);

    final MaterialPageRoute<Widget> route = MaterialPageRoute<Widget>(
      builder: (BuildContext context) => getPageWidget(context, page),
    );

    if (page == OnboardingPage.ONBOARDING_COMPLETE) {
      Navigator.pushAndRemoveUntil(
        context,
        route,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.push<Widget>(context, route);
    }
  }

  Widget getPageWidget(BuildContext context, OnboardingPage page) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    switch (page) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.REINVENTION:
        return ReinventionPage(getBackgroundColor(page));
      case OnboardingPage.WELCOME:
        return WelcomePage(getBackgroundColor(page));
      case OnboardingPage.SCAN_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          page,
          ScanExample(getBackgroundColor(page)),
        );
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          page,
          SampleHealthCardPage(localDatabase, getBackgroundColor(page)),
        );
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          page,
          SampleEcoCardPage(localDatabase, getBackgroundColor(page)),
        );
      case OnboardingPage.PREFERENCES_PAGE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          page,
          PreferencesPage(localDatabase, getBackgroundColor(page)),
        );
      case OnboardingPage.CONSENT_PAGE:
        return _wrapWidgetInCustomBackNavigator(
          context,
          page,
          ConsentAnalytics(getBackgroundColor(page)),
        );
      case OnboardingPage.ONBOARDING_COMPLETE:
        return InheritedDataManager(child: PageManager());
    }
  }

  Color getBackgroundColor(final OnboardingPage page) {
    switch (page) {
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
      case OnboardingPage.CONSENT_PAGE:
        return const Color(0xFFFFF2DF);
      case OnboardingPage.ONBOARDING_COMPLETE:
        // whatever, it's not used
        return Colors.black;
    }
  }

  Widget _wrapWidgetInCustomBackNavigator(
      BuildContext context, OnboardingPage currentPage, Widget widget) {
    return WillPopScope(
      onWillPop: () async => false,
      // wrap the widget in [Builder] to allow navigation on the [context].
      child: Builder(
        builder: (BuildContext context) => SmoothScaffold(
          body: widget,
        ),
      ),
    );
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
