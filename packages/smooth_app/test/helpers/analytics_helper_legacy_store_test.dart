import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/query/product_query.dart';

import '../tests_utils/mocks.dart';

/// Preferences written by a build that predates this feature: `init` has
/// already run, and `firstOpenTracked` does not exist.
///
/// `UserPreferences` is a per-isolate singleton, so a store in that state can
/// only be set up in a file of its own.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Iterable<Map<String, String>> appFirstOpenEvents() => MatomoTracker
      .instance
      .queue
      .where((Map<String, String> event) => event['e_n'] == 'appFirstOpen');

  test(
    'an upgrade reports no first open, nor does a consent tap after it',
    () async {
      SharedPreferences.setMockInitialValues(mockSharedPreferences());
      await mockMatomo();
      final UserPreferences userPreferences =
          await UserPreferences.getUserPreferences();
      // trackCustomEvent reads ProductQuery's `late` country/language globals.
      await ProductQuery.setCountry(userPreferences, 'fr');
      MatomoTracker.instance.dropActions();

      final ProductPreferences productPreferences = ProductPreferences(
        ProductPreferencesSelection(
          setImportance: userPreferences.setImportance,
          getImportance: userPreferences.getImportance,
          notify: () {},
        ),
      );

      // The upgrade itself: migrations run, and nothing at all is reported -
      // the whole queue, not just this event, because a pre-consent event of
      // any kind would break the same rule.
      await userPreferences.init(productPreferences);
      expect(MatomoTracker.instance.queue, isEmpty);

      // The migration latched the store: this install opened the app before
      // the event existed, so a consent tap after the upgrade (a sign-up or
      // dev-mode reset re-runs the onboarding) must not count as a first open.
      await userPreferences.trackFirstOpenAfterConsent();
      expect(appFirstOpenEvents(), isEmpty);
    },
  );
}
