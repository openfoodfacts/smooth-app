import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/pages/donation/donation_reminder_conditions.dart';

void main() {
  group('DonationReminderConditions.eligible', () {
    DonationReminderConditions base({
      bool campaignLive = true,
      int productsLookedUp = 10,
      int every = 10,
      bool muted = false,
      int appLaunches = 2,
      DateTime? lastShownAt,
      DateTime? now,
    }) => DonationReminderConditions(
      campaignLive: campaignLive,
      productsLookedUp: productsLookedUp,
      every: every,
      muted: muted,
      appLaunches: appLaunches,
      lastShownAt: lastShownAt,
      now: now ?? DateTime(2026, 9, 20),
    );

    test('true when every clause holds', () {
      expect(base().eligible, isTrue);
    });

    test('false when the campaign is not live', () {
      expect(base(campaignLive: false).eligible, isFalse);
    });

    test('false below the threshold, true at and above it', () {
      expect(base(productsLookedUp: 9, every: 10).eligible, isFalse);
      expect(base(productsLookedUp: 10, every: 10).eligible, isTrue);
      expect(base(productsLookedUp: 15, every: 10).eligible, isTrue);
    });

    test('false when muted', () {
      expect(base(muted: true).eligible, isFalse);
    });

    test('false in the install session, true from the second launch', () {
      expect(base(appLaunches: 1).eligible, isFalse);
      expect(base(appLaunches: 2).eligible, isTrue);
    });

    test('true when never shown', () {
      expect(base(lastShownAt: null).eligible, isTrue);
    });

    test('false 29 days after the last show, true at 30', () {
      final DateTime now = DateTime(2026, 9, 20);
      expect(
        base(
          lastShownAt: now.subtract(const Duration(days: 29)),
          now: now,
        ).eligible,
        isFalse,
      );
      expect(
        base(
          lastShownAt: now.subtract(const Duration(days: 30)),
          now: now,
        ).eligible,
        isTrue,
      );
    });
  });
}
