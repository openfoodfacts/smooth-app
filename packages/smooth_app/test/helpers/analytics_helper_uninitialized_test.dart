import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// Deliberately never calls `mockMatomo()`: the tracker is a per-isolate
/// singleton, so an uninitialized one only exists in its own test file.
void main() {
  test('trackEvent no-ops when the tracker was never initialized', () {
    expect(MatomoTracker.instance.initialized, isFalse);

    expect(
      () => AnalyticsHelper.trackEvent(
        AnalyticsEvent.onboardingPageVisited,
        action: 'WELCOME',
      ),
      returnsNormally,
    );

    // `queue` is a `late final` assigned only inside `initialize()`; still
    // unassigned proves nothing was enqueued.
    expect(() => MatomoTracker.instance.queue, throwsA(isA<Error>()));
  });
}
