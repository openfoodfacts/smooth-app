import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/consent_analytics_page.dart';
import 'package:smooth_app/pages/onboarding/preferences_page.dart';
import 'package:smooth_app/pages/onboarding/sample_eco_card_page.dart';
import 'package:smooth_app/pages/onboarding/sample_health_card_page.dart';
import 'package:smooth_app/pages/onboarding/scan_example.dart';
import 'package:smooth_app/pages/onboarding/welcome_page.dart';
import 'package:smooth_app/pages/page_manager.dart';

enum OnboardingPage {
  NOT_STARTED,
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

  static OnboardingPage _getPrevPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.WELCOME:
        return OnboardingPage.NOT_STARTED;
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

  void navigateToPage(BuildContext context, OnboardingPage page) {
    _userPreferences.setLastVisitedOnboardingPage(page);
    _historyOnboardingNav.add(page);
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => getPageWidget(context, page),
      ),
    );
  }

  Widget getPageWidget(BuildContext context, OnboardingPage page) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    switch (page) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.WELCOME:
        return const WelcomePage();
      case OnboardingPage.SCAN_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, const ScanExample());
      case OnboardingPage.HEALTH_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, SampleHealthCardPage(localDatabase));
      case OnboardingPage.ECO_CARD_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, SampleEcoCardPage(localDatabase));
      case OnboardingPage.PREFERENCES_PAGE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, PreferencesPage(localDatabase));
      case OnboardingPage.CONSENT_PAGE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, const ConsentAnalytics());
      case OnboardingPage.ONBOARDING_COMPLETE:
        return PageManager();
    }
  }

  Widget _wrapWidgetInCustomBackNavigator(
      BuildContext context, OnboardingPage currentPage, Widget widget) {
    return WillPopScope(
      onWillPop: () async => false,
      // wrap the widget in [Builder] to allow navigation on the [context].
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          body: widget,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  navigateToPage(context, _getPrevPage(currentPage)),
            ),
          ),
        ),
      ),
    );
  }

  static bool isOnboradingPagedInHistory(OnboardingPage page) {
    bool exists = false;
    if (_historyOnboardingNav.isNotEmpty) {
      final int indexPage = _historyOnboardingNav.indexOf(page);
      exists = indexPage >= 0 && indexPage < (_historyOnboardingNav.length - 1);
    }
    return exists;
  }
}
