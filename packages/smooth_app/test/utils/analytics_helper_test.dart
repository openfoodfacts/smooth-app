import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

import '../tests_utils/mocks.dart';

void main() {
  test(
    'When user opts out then init Matomo with userId of 0000000000000000',
    () async {
      // arrange
      const bool allowAnalytics = false;
      const bool isScreenshotMode = false;
      final MatomoTracker matomoTrackerInstance = MatomoTracker.instance;
      SharedPreferences.setMockInitialValues(
        mockSharedPreferences(),
      );
      mockPackageInfo();
      WidgetsFlutterBinding.ensureInitialized();
      mockPackageInfo();
      // act
      await AnalyticsHelper.setAnalyticsReports(allowAnalytics);
      await AnalyticsHelper.initMatomo(isScreenshotMode);
      // assert
      final String? matomoUserId = matomoTrackerInstance.visitor.userId;
      expect(matomoUserId, '0000000000000000');
    },
  );
}
