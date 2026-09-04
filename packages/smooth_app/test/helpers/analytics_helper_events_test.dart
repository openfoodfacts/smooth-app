import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/query/product_query.dart';

import '../tests_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await mockMatomo();
    // trackCustomEvent reads ProductQuery.getCountry()/getLanguage(), both
    // `late` - a fresh test isolate has never set them.
    userPreferences = await UserPreferences.getUserPreferences();
    await ProductQuery.setCountry(userPreferences, 'fr');
  });

  setUp(() {
    MatomoTracker.instance.dropActions();
  });

  group('enum shape', () {
    test(
      'the new categories and events are appended last, with their tags',
      () {
        const List<AnalyticsCategory> categories = AnalyticsCategory.values;
        expect(categories[categories.length - 3], AnalyticsCategory.lifecycle);
        expect(categories[categories.length - 2], AnalyticsCategory.onboarding);
        expect(categories.last, AnalyticsCategory.knowledgePanel);
        expect(AnalyticsCategory.lifecycle.tag, 'lifecycle');
        expect(AnalyticsCategory.onboarding.tag, 'onboarding');
        expect(AnalyticsCategory.knowledgePanel.tag, 'knowledge panel');

        const List<AnalyticsEvent> events = AnalyticsEvent.values;
        expect(events[events.length - 3], AnalyticsEvent.appFirstOpen);
        expect(events[events.length - 2], AnalyticsEvent.onboardingPageVisited);
        expect(events.last, AnalyticsEvent.knowledgePanelOpen);
        expect(AnalyticsEvent.appFirstOpen.tag, 'app first open');
        expect(
          AnalyticsEvent.appFirstOpen.category,
          AnalyticsCategory.lifecycle,
        );
        expect(
          AnalyticsEvent.onboardingPageVisited.tag,
          'onboarding page visited',
        );
        expect(
          AnalyticsEvent.onboardingPageVisited.category,
          AnalyticsCategory.onboarding,
        );
        expect(AnalyticsEvent.knowledgePanelOpen.tag, 'knowledge panel open');
        expect(
          AnalyticsEvent.knowledgePanelOpen.category,
          AnalyticsCategory.knowledgePanel,
        );
      },
    );
  });

  group('trackEvent payloads', () {
    test('appFirstOpen enqueues category/name/action, no barcode value', () {
      AnalyticsHelper.trackEvent(AnalyticsEvent.appFirstOpen);

      final Map<String, String> event = MatomoTracker.instance.queue.single;
      expect(event['e_c'], 'lifecycle');
      expect(event['e_n'], 'appFirstOpen');
      expect(event['e_a'], 'appFirstOpen');
      expect(event.containsKey('e_v'), isFalse);
    });

    test('the new action parameter reaches trackCustomEvent', () {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.knowledgePanelOpen,
        action: 'nutriscore',
      );

      final Map<String, String> event = MatomoTracker.instance.queue.single;
      expect(event['e_c'], 'knowledge panel');
      expect(event['e_a'], 'nutriscore');
    });
  });

  group('UserPreferences analytics', () {
    test(
      'init() reports nothing: the first launch happens before consent',
      () async {
        final ProductPreferences productPreferences = ProductPreferences(
          ProductPreferencesSelection(
            setImportance: userPreferences.setImportance,
            getImportance: userPreferences.getImportance,
            notify: () {},
          ),
        );

        await userPreferences.init(productPreferences);
        expect(MatomoTracker.instance.queue, isEmpty);
      },
    );

    test(
      'appFirstOpen fires once, at the consent tap, and never twice',
      () async {
        await userPreferences.trackFirstOpenAfterConsent();
        expect(
          MatomoTracker.instance.queue.where(
            (Map<String, String> event) => event['e_n'] == 'appFirstOpen',
          ),
          hasLength(1),
        );

        // A second consent tap, or a relaunch mid-onboarding: nothing new.
        await userPreferences.trackFirstOpenAfterConsent();
        expect(
          MatomoTracker.instance.queue.where(
            (Map<String, String> event) => event['e_n'] == 'appFirstOpen',
          ),
          hasLength(1),
        );
      },
    );

    test('onboardingPageVisited fires once per call, '
        'and again (replayably) after resetOnboarding', () async {
      await userPreferences.setLastVisitedOnboardingPage(
        OnboardingPage.WELCOME,
      );
      await userPreferences.setLastVisitedOnboardingPage(
        OnboardingPage.PREFERENCES_PAGE,
      );

      final List<Map<String, String>> events = MatomoTracker.instance.queue
          .where(
            (Map<String, String> event) =>
                event['e_n'] == 'onboardingPageVisited',
          )
          .toList();
      expect(events, hasLength(2));
      expect(events[0]['e_a'], 'WELCOME');
      expect(events[1]['e_a'], 'PREFERENCES_PAGE');

      await userPreferences.resetOnboarding();

      final List<Map<String, String>> eventsAfterReset = MatomoTracker
          .instance
          .queue
          .where(
            (Map<String, String> event) =>
                event['e_n'] == 'onboardingPageVisited',
          )
          .toList();
      expect(eventsAfterReset, hasLength(3));
      expect(eventsAfterReset.last['e_a'], 'NOT_STARTED');
    });
  });
}
