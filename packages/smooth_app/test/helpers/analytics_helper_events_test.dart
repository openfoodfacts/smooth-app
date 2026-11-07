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
        expect(categories.sublist(categories.length - 5), <AnalyticsCategory>[
          AnalyticsCategory.lifecycle,
          AnalyticsCategory.onboarding,
          AnalyticsCategory.knowledgePanel,
          AnalyticsCategory.navigation,
          AnalyticsCategory.foodPreferences,
        ]);
        expect(AnalyticsCategory.navigation.tag, 'navigation');
        expect(AnalyticsCategory.foodPreferences.tag, 'food preferences');

        const List<AnalyticsEvent> events = AnalyticsEvent.values;
        expect(events.sublist(events.length - 11), <AnalyticsEvent>[
          AnalyticsEvent.appFirstOpen,
          AnalyticsEvent.onboardingPageVisited,
          AnalyticsEvent.knowledgePanelOpen,
          AnalyticsEvent.appOpen,
          AnalyticsEvent.productPageTabSelected,
          AnalyticsEvent.bottomTabSelected,
          AnalyticsEvent.foodPreferenceSaved,
          AnalyticsEvent.questionAnswered,
          AnalyticsEvent.cameraPermissionRefused,
          AnalyticsEvent.userListCreated,
          AnalyticsEvent.userListProductAdded,
        ]);

        final Map<AnalyticsEvent, (String, AnalyticsCategory)> expected =
            <AnalyticsEvent, (String, AnalyticsCategory)>{
              AnalyticsEvent.appOpen: ('app open', AnalyticsCategory.lifecycle),
              AnalyticsEvent.appFirstOpen: (
                'app first open',
                AnalyticsCategory.lifecycle,
              ),
              AnalyticsEvent.onboardingPageVisited: (
                'onboarding page visited',
                AnalyticsCategory.onboarding,
              ),
              AnalyticsEvent.knowledgePanelOpen: (
                'knowledge panel open',
                AnalyticsCategory.knowledgePanel,
              ),
              AnalyticsEvent.productPageTabSelected: (
                'product page tab selected',
                AnalyticsCategory.navigation,
              ),
              AnalyticsEvent.bottomTabSelected: (
                'bottom tab selected',
                AnalyticsCategory.navigation,
              ),
              AnalyticsEvent.foodPreferenceSaved: (
                'food preference saved',
                AnalyticsCategory.foodPreferences,
              ),
              AnalyticsEvent.questionAnswered: (
                'question answered',
                AnalyticsCategory.hungerGame,
              ),
              AnalyticsEvent.cameraPermissionRefused: (
                'camera permission refused',
                AnalyticsCategory.scanning,
              ),
              AnalyticsEvent.userListCreated: (
                'user list created',
                AnalyticsCategory.list,
              ),
              AnalyticsEvent.userListProductAdded: (
                'product added to user list',
                AnalyticsCategory.list,
              ),
            };
        expected.forEach((
          AnalyticsEvent event,
          (String, AnalyticsCategory) tagAndCategory,
        ) {
          expect(event.tag, tagAndCategory.$1, reason: event.name);
          expect(event.category, tagAndCategory.$2, reason: event.name);
        });
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

  group('trackAppOpen', () {
    List<Map<String, String>> appOpenEvents() => MatomoTracker.instance.queue
        .where((Map<String, String> event) => event['e_n'] == 'appOpen')
        .toList();

    test(
      'a cold start after consent fires one event with dimensions',
      () async {
        await userPreferences.setLastVisitedOnboardingPage(
          OnboardingPage.WELCOME,
        );

        ProductQuery.setLanguage(null, userPreferences, languageCode: 'de');
        AnalyticsHelper.trackAppOpen(userPreferences);

        final List<Map<String, String>> events = appOpenEvents();
        expect(events, hasLength(1));
        expect(events.single['e_c'], 'lifecycle');
        expect(events.single['dimension1'], 'de');
        expect(events.single['dimension4'], isNotEmpty);
      },
    );

    test('a return after 30 minutes or more fires', () async {
      await userPreferences.setLastVisitedOnboardingPage(
        OnboardingPage.WELCOME,
      );

      AnalyticsHelper.trackAppOpen(
        userPreferences,
        backgroundedFor: const Duration(minutes: 30),
      );
      AnalyticsHelper.trackAppOpen(
        userPreferences,
        backgroundedFor: const Duration(hours: 2),
      );

      expect(appOpenEvents(), hasLength(2));
    });

    test('a return after less than 30 minutes fires nothing', () async {
      await userPreferences.setLastVisitedOnboardingPage(
        OnboardingPage.WELCOME,
      );

      AnalyticsHelper.trackAppOpen(
        userPreferences,
        backgroundedFor: const Duration(minutes: 29, seconds: 59),
      );

      expect(appOpenEvents(), isEmpty);
    });

    test('nothing fires before consent', () async {
      await userPreferences.resetOnboarding();

      AnalyticsHelper.trackAppOpen(userPreferences);
      AnalyticsHelper.trackAppOpen(
        userPreferences,
        backgroundedFor: const Duration(hours: 2),
      );

      expect(appOpenEvents(), isEmpty);
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

        // And a double tap on the undebounced consent button: two calls
        // interleaving on the stored flag before either has written it.
        await Future.wait(<Future<void>>[
          userPreferences.trackFirstOpenAfterConsent(),
          userPreferences.trackFirstOpenAfterConsent(),
        ]);
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
