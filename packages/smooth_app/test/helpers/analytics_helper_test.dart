import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

import '../tests_utils/mocks.dart';

/// Where `matomo_tracker` stores pending actions. Pinned rather than imported
/// because the package does not export it.
const String _kMatomoPersistentQueue = 'matomo_persistent_queue';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initMatomo', () {
    // Not a widget test: the persistent queue saves through a zero-duration
    // timer, which needs a real event loop.
    test(
      'defaults to a dispatch queue that survives app termination',
      () async {
        SharedPreferences.setMockInitialValues(mockSharedPreferences());
        mockMatomoPlatformChannels();

        await AnalyticsHelper.initMatomo(false);
        await MatomoTracker.instance.setOptOut(optOut: true);
        MatomoTracker.instance.dequeueTimer.cancel();
        MatomoTracker.instance.pingTimer?.cancel();

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        expect(preferences.getString(_kMatomoPersistentQueue), isNotNull);
      },
    );
  });
}
