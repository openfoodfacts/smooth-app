import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

import '../../tests_utils/mocks.dart';

const String _tagMutedUntil = 'donationAsksMutedUntil';
const String _tagBucket = 'donationTestBucket';
const String _tagStripHiddenUntil = 'donationStripHiddenUntil';
const String _tagProductsLookedUp = 'productsLookedUpSinceAsk';
const String _tagLastCountedBarcode = 'lastCountedBarcode';
const String _tagLastReminderShownAt = 'lastReminderShownAt';
const String _tagUserPictureSource = 'userPictureSource';
const String _tagLastPictureSource = 'lastPictureSource';

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
    await sharedPreferences.remove(_tagBucket);
    await sharedPreferences.remove(_tagStripHiddenUntil);
    await sharedPreferences.remove(_tagProductsLookedUp);
    await sharedPreferences.remove(_tagLastCountedBarcode);
    await sharedPreferences.remove(_tagLastReminderShownAt);
    await sharedPreferences.remove(_tagUserPictureSource);
    await sharedPreferences.remove(_tagLastPictureSource);
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

  group('getDonationTestBucket', () {
    test('draws once in 0..99 and answers the same afterwards', () {
      final int bucket = userPreferences.getDonationTestBucket();

      expect(bucket, inInclusiveRange(0, 99));
      expect(sharedPreferences.getInt(_tagBucket), bucket);
      expect(userPreferences.getDonationTestBucket(), bucket);
    });

    test('keeps a stored bucket', () async {
      await sharedPreferences.setInt(_tagBucket, 42);

      expect(userPreferences.getDonationTestBucket(), 42);
    });
  });

  test('hideDonationStrip hides only the strip, for the given days', () async {
    expect(userPreferences.donationStripHidden(DateTime.now()), isFalse);

    await userPreferences.hideDonationStrip(const Duration(days: 14));

    expect(userPreferences.donationStripHidden(DateTime.now()), isTrue);
    expect(
      userPreferences.donationStripHidden(
        DateTime.now().add(const Duration(days: 15)),
      ),
      isFalse,
    );
    expect(userPreferences.donationAsksMutedUntil, isNull);
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

    test('two unawaited calls for one barcode count once', () {
      unawaited(userPreferences.countProductLookedUp('3017620422003'));
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

  group('picture source preferences and precedence', () {
    test('initial state has no explicit preference and no last source', () {
      expect(userPreferences.explicitUserPictureSource, isNull);
      expect(userPreferences.lastPictureSource, isNull);
      expect(userPreferences.userPictureSource, UserPictureSource.SELECT);
    });

    test('setLastPictureSource persists and notifies', () async {
      int notified = 0;
      void listener() => notified++;
      userPreferences.addListener(listener);
      addTearDown(() => userPreferences.removeListener(listener));

      await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);
      expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);
      expect(sharedPreferences.getString(_tagLastPictureSource), 'C');
      expect(notified, 1);

      await userPreferences.setLastPictureSource(UserPictureSource.GALLERY);
      expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
      expect(sharedPreferences.getString(_tagLastPictureSource), 'G');
      expect(notified, 2);

      // Setting SELECT as last source is a no-op
      await userPreferences.setLastPictureSource(UserPictureSource.SELECT);
      expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
      expect(sharedPreferences.getString(_tagLastPictureSource), 'G');
      expect(notified, 2);

      await sharedPreferences.remove(_tagLastPictureSource);
      expect(userPreferences.lastPictureSource, isNull);
      expect(sharedPreferences.getString(_tagLastPictureSource), isNull);
    });

    test('explicitUserPictureSource reads saved explicit preference', () async {
      await sharedPreferences.setString(_tagUserPictureSource, 'C');
      expect(
        userPreferences.explicitUserPictureSource,
        UserPictureSource.CAMERA,
      );

      await sharedPreferences.setString(_tagUserPictureSource, 'G');
      expect(
        userPreferences.explicitUserPictureSource,
        UserPictureSource.GALLERY,
      );

      await sharedPreferences.setString(_tagUserPictureSource, 'S');
      expect(
        userPreferences.explicitUserPictureSource,
        UserPictureSource.SELECT,
      );

      await sharedPreferences.setString(_tagUserPictureSource, 'INVALID');
      expect(userPreferences.explicitUserPictureSource, isNull);
    });

    test('setUserPictureSource updates explicit preference', () async {
      await userPreferences.setUserPictureSource(UserPictureSource.CAMERA);
      expect(
        userPreferences.explicitUserPictureSource,
        UserPictureSource.CAMERA,
      );
      expect(userPreferences.userPictureSource, UserPictureSource.CAMERA);

      await sharedPreferences.remove(_tagUserPictureSource);
      expect(userPreferences.explicitUserPictureSource, isNull);
      expect(userPreferences.userPictureSource, UserPictureSource.SELECT);
    });

    test(
      'precedence: explicit preference overrides lastPictureSource',
      () async {
        await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);

        // 1. Explicit GALLERY overrides last CAMERA
        await userPreferences.setUserPictureSource(UserPictureSource.GALLERY);
        expect(userPreferences.userPictureSource, UserPictureSource.GALLERY);

        // 2. Explicit SELECT ("Ask each time") overrides last CAMERA
        await userPreferences.setUserPictureSource(UserPictureSource.SELECT);
        expect(userPreferences.userPictureSource, UserPictureSource.SELECT);

        // 3. Without explicit preference, last source is used
        await sharedPreferences.remove(_tagUserPictureSource);
        expect(userPreferences.userPictureSource, UserPictureSource.CAMERA);

        // 4. Without explicit preference and without last source, defaults to SELECT
        await sharedPreferences.remove(_tagLastPictureSource);
        expect(userPreferences.userPictureSource, UserPictureSource.SELECT);
      },
    );
  });
}
