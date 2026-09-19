import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

import '../../tests_utils/mocks.dart';

const String _tagMutedUntil = 'donationAsksMutedUntil';
const String _tagRemindersDisabled = 'donationRemindersDisabled';

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
    await sharedPreferences.remove(_tagRemindersDisabled);
  });

  group('donationAsksMuted', () {
    final DateTime now = DateTime(2026, 9, 19, 12);

    test('is false with nothing set', () {
      expect(userPreferences.donationAsksMutedUntil, isNull);
      expect(userPreferences.donationRemindersDisabled, isFalse);
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

    test('is true when reminders are disabled, whatever the date', () async {
      await userPreferences.setDonationRemindersDisabled(true);

      expect(userPreferences.donationAsksMutedUntil, isNull);
      expect(userPreferences.donationAsksMuted(now), isTrue);
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
}
