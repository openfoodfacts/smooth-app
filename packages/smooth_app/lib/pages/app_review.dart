import 'package:flutter/cupertino.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

class AppReviewProvider extends ValueNotifier<AppReviewState> {
  AppReviewProvider(this.userPreferences) : super(AppReviewState.checking) {
    check();
  }

  final UserPreferences userPreferences;

  static const int _APP_MIN_LAUNCHES = 5; // wait for 5 launches
  static const int _APP_REVIEW_FREQUENCY = 4; // then every 4 launches

  Future<void> check() async {
    final bool hasAlreadyReviewed = userPreferences.inAppReviewAlreadyAsked;

    if (hasAlreadyReviewed) {
      value = AppReviewState.ignore;
      return;
    }

    final int appLaunches = userPreferences.appLaunches;
    if (appLaunches > _APP_MIN_LAUNCHES &&
        (appLaunches - _APP_MIN_LAUNCHES) % _APP_REVIEW_FREQUENCY == 0) {
      value = AppReviewState.askForReview;
      return;
    }

    value = AppReviewState.ignore;
  }

  void hide() {
    value = AppReviewState.ignore;
  }

  void markAsReviewed(AppReviewResult result) {
    userPreferences.markInAppReviewAsShown();
    value = AppReviewState.ignore;

    AnalyticsHelper.trackEvent(switch (result) {
      AppReviewResult.satisfied => AnalyticsEvent.appRatingSatisfied,
      AppReviewResult.neutral => AnalyticsEvent.appRatingNeutral,
      AppReviewResult.unsatisfied => AnalyticsEvent.appRatingNotSatisfied,
    });
  }
}

enum AppReviewState {
  checking,
  askForReview,
  ignore,
}

enum AppReviewResult {
  satisfied,
  neutral,
  unsatisfied,
}
