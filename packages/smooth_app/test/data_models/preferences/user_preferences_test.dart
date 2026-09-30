import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

import '../../tests_utils/mocks.dart';

const String _tagMutedUntil = 'donationAsksMutedUntil';
const String _tagProductsLookedUp = 'productsLookedUpSinceAsk';
const String _tagLastCountedBarcode = 'lastCountedBarcode';
const String _tagLastReminderShownAt = 'lastReminderShownAt';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late SharedPreferences sharedPreferences;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();
    sharedPreferences = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await sharedPreferences.remove(_tagMutedUntil);
    await sharedPreferences.remove(_tagProductsLookedUp);
    await sharedPreferences.remove(_tagLastCountedBarcode);
    await sharedPreferences.remove(_tagLastReminderShownAt);
  });

  group('donationAsksMuted', () {
    final DateTime now = DateTime(2026, 9, 19, 12);

    test('is false with nothing set', () {
      expect(userPreferences.donationAsksMutedUntil, isNull);
      expect(userPreferences.donationAsksMuted(now), isFalse);
    });

    test('is true until the mute expires, then false', () async {
      await sharedPreferences.setInt(
        _tagMutedUntil,
        now.add(const Duration(seconds: 1)).millisecondsSinceEpoch,
      );
      expect(userPreferences.donationAsksMuted(now), isTrue);

      await sharedPreferences.setInt(
        _tagMutedUntil,
        now.subtract(const Duration(seconds: 1)).millisecondsSinceEpoch,
      );
      expect(userPreferences.donationAsksMuted(now), isFalse);
    });
  });

  test('muteDonationAsks mutes for the given duration and notifies', () async {
    int notified = 0;
    void onChanged() => notified++;
    userPreferences.addListener(onChanged);
    addTearDown(() => userPreferences.removeListener(onChanged));

    final DateTime before = DateTime.now();
    await userPreferences.muteDonationAsks(const Duration(days: 365));

    final DateTime? mutedUntil = userPreferences.donationAsksMutedUntil;
    expect(mutedUntil, isNotNull);
    expect(
      mutedUntil!.difference(before.add(const Duration(days: 365))).abs(),
      lessThan(const Duration(seconds: 5)),
    );
    expect(userPreferences.donationAsksMuted(DateTime.now()), isTrue);
    expect(
      userPreferences.donationAsksMuted(
        DateTime.now().add(const Duration(days: 366)),
      ),
      isFalse,
    );
    expect(notified, 1);
  });

  group('countProductLookedUp', () {
    test('the same barcode ten times counts once', () async {
      for (int i = 0; i < 10; i++) {
        await userPreferences.countProductLookedUp('3017620422003');
      }
      expect(userPreferences.productsLookedUpSinceAsk, 1);
      expect(userPreferences.lastCountedBarcode, '3017620422003');
    });

    test(
      'A, B, A counts three: only the immediately last one dedupes',
      () async {
        await userPreferences.countProductLookedUp('A');
        await userPreferences.countProductLookedUp('B');
        await userPreferences.countProductLookedUp('A');
        expect(userPreferences.productsLookedUpSinceAsk, 3);
        expect(userPreferences.lastCountedBarcode, 'A');
      },
    );

    test('a fired-but-unawaited call still lands synchronously', () {
      expect(userPreferences.productsLookedUpSinceAsk, 0);
      // Deliberately not awaited: `DonationReminderScope.initState` cannot
      // await, so a synchronous read right after must already see it.
      unawaited(userPreferences.countProductLookedUp('3017620422003'));
      expect(userPreferences.productsLookedUpSinceAsk, 1);
    });
  });

  test('markDonationReminderShown resets the counter and stamps now', () async {
    await userPreferences.countProductLookedUp('3017620422003');
    expect(userPreferences.productsLookedUpSinceAsk, 1);

    final DateTime before = DateTime.now();
    await userPreferences.markDonationReminderShown();

    expect(userPreferences.productsLookedUpSinceAsk, 0);
    final DateTime? shownAt = userPreferences.lastReminderShownAt;
    expect(shownAt, isNotNull);
    expect(
      shownAt!.difference(before).abs(),
      lessThan(const Duration(seconds: 5)),
    );
  });
}
