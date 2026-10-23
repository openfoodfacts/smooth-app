import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/app_review.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_page.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_provider.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/scan_main_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/top_card/scan_search_card.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/autosize_text.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

// `UserPreferences` is a per-isolate singleton, so each test clears the keys
// it can leave behind on the shared `SharedPreferences` instance.
const String _tagMutedUntil = 'donationAsksMutedUntil';
const String _tagStripHiddenUntil = 'donationStripHiddenUntil';
const String _tagDisplayed = 'taglineFeedNewsDisplayed';
const String _tagClicked = 'taglineFeedNewsClicked';

const String _alreadyDonated = 'I already donated';
const String _stripHeadline =
    'Open Food Facts is funded by the people who use it';

const AppNewsItem _donation = AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
);

/// Every install lands on the reminder side of the donation test.
const AppNewsItem _donationReminderArm = AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
  donationAbNewPercent: 100,
);

const AppNewsItem _donationWithFigures = AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
  donationAbNewPercent: 100,
  raised: 51000,
  goal: 170000,
  currency: 'EUR',
);

const AppNewsItem _other = AppNewsItem(
  id: 'news-0',
  title: 'First news',
  message: 'First message',
  url: 'https://example.com/0',
);

/// Serves a fixed feed; the real fetch is a no-op.
class _FeedNewsProvider extends AppNewsProvider {
  _FeedNewsProvider(super.preferences, this._feed);

  final List<AppNewsItem> _feed;

  @override
  AppNewsState get state => AppNewsStateLoaded(
    AppNews(
      news: const AppNewsList(<String, AppNewsItem>{}),
      feed: AppNewsFeed(<AppNewsFeedItem>[
        for (final AppNewsItem item in _feed) AppNewsFeedItem(news: item),
      ]),
    ),
    DateTime(2026),
  );

  @override
  Future<void> loadLatestNews({bool forceUpdate = false}) async {}
}

Finder _titleFinder(String title) => find.byWidgetPredicate(
  (Widget widget) => widget is AutoSizeText && widget.text == title,
);

Iterable<String> _ids(ScanNewsFeedProvider provider) =>
    (provider.value as ScanTagLineStateLoaded).tagLine.map(
      (AppNewsItem item) => item.id,
    );

Future<ScanNewsFeedProvider> _pumpProvider(
  WidgetTester tester,
  UserPreferences userPreferences,
  List<AppNewsItem> feed,
) async {
  final AppNewsProvider news = _FeedNewsProvider(userPreferences, feed);
  addTearDown(news.dispose);

  late ScanNewsFeedProvider provider;
  await tester.pumpWidget(
    MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<UserPreferences>.value(value: userPreferences),
        ChangeNotifierProvider<AppNewsProvider>.value(value: news),
        ChangeNotifierProvider<ScanNewsFeedProvider>(
          create: (BuildContext context) => ScanNewsFeedProvider(context),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          provider = context.read<ScanNewsFeedProvider>();
          return const SizedBox();
        },
      ),
    ),
  );
  return provider;
}

Future<void> _pumpMainCard(
  WidgetTester tester,
  UserPreferences userPreferences,
  List<AppNewsItem> feed,
) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  late ProductPreferences productPreferences;
  productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () => productPreferences.notifyListeners(),
    ),
  );
  await productPreferences.init(PlatformAssetBundle());
  await userPreferences.init(productPreferences);

  final AppNewsProvider news = _FeedNewsProvider(userPreferences, feed);
  addTearDown(news.dispose);
  final AppReviewProvider appReview = AppReviewProvider(userPreferences);
  addTearDown(appReview.dispose);

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<AppNewsProvider>.value(value: news),
          ChangeNotifierProvider<AppReviewProvider>.value(value: appReview),
        ],
        child: const ScanMainCard(),
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

/// WCAG contrast ratio of [text]'s colour against the strip's background.
double _stripContrast(WidgetTester tester, String text) {
  final Finder label = find.text(text);
  final Color background = tester
      .widget<Material>(
        find.ancestor(of: label, matching: find.byType(Material)).first,
      )
      .color!;
  final Color foreground = tester
      .renderObject<RenderParagraph>(label)
      .text
      .style!
      .color!;
  final double a = foreground.computeLuminance() + 0.05;
  final double b = background.computeLuminance() + 0.05;
  return a > b ? a / b : b / a;
}

ScanSearchCard _searchCard(WidgetTester tester) =>
    tester.widget<ScanSearchCard>(find.byType(ScanSearchCard));

Future<void> _alreadyDonateFromSupport(WidgetTester tester) async {
  final NavigatorState navigator = Navigator.of(
    tester.element(find.byType(ScanMainCard)),
  );
  unawaited(
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const DonationPage(source: DonationSource.settings),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text(_alreadyDonated));
  await tester.pump();
  await tester.tap(find.text(_alreadyDonated));
  await tester.pump();

  navigator.pop();
  await tester.pumpAndSettle();
}

void main() {
  late UserPreferences userPreferences;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();
    ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
    await ProductQuery.setCountry(userPreferences, 'fr');
  });

  setUp(() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tagMutedUntil);
    await prefs.remove(_tagStripHiddenUntil);
    await prefs.setStringList(_tagDisplayed, <String>[]);
    await prefs.setStringList(_tagClicked, <String>[]);
    userPreferences.taglineFeedSessionImpressions.clear();
    userPreferences.taglineFeedSessionClicks.clear();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('ScanNewsFeedProvider', () {
    testWidgets('not muted keeps every item', (WidgetTester tester) async {
      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donation, _other],
      );

      expect(
        _ids(provider),
        unorderedEquals(<String>[_donation.id, _other.id]),
      );
    });

    testWidgets('muted drops the donation item and nothing else', (
      WidgetTester tester,
    ) async {
      await userPreferences.muteDonationAsks(const Duration(days: 365));

      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donation, _other],
      );

      expect(_ids(provider), <String>[_other.id]);
      // The parser is untouched: the Support screen still gets its ladder.
      final AppNewsState news = tester
          .element(find.byType(SizedBox))
          .read<AppNewsProvider>()
          .state;
      expect((news as AppNewsStateLoaded).content.donation, isNotNull);
    });

    testWidgets('muted with only a donation item has no content', (
      WidgetTester tester,
    ) async {
      await userPreferences.muteDonationAsks(const Duration(days: 365));

      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donation],
      );

      expect(provider.value, isA<ScanTagLineStateNoContent>());
    });

    testWidgets('the list follows the mute without a feed reload', (
      WidgetTester tester,
    ) async {
      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donation, _other],
      );
      expect(_ids(provider), hasLength(2));

      await userPreferences.muteDonationAsks(const Duration(days: 365));
      await tester.pump();
      expect(_ids(provider), <String>[_other.id]);

      await userPreferences.muteDonationAsks(const Duration(days: -1));
      await tester.pump();
      expect(_ids(provider), hasLength(2));
    });
  });

  group('ScanNewsFeedProvider on the reminder side of the donation test', () {
    ScanTagLineStateLoaded loaded(ScanNewsFeedProvider provider) =>
        provider.value as ScanTagLineStateLoaded;

    testWidgets('drops the donation item, keeps the others, shows the strip', (
      WidgetTester tester,
    ) async {
      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm, _other],
      );

      expect(_ids(provider), <String>[_other.id]);
      expect(loaded(provider).donationStrip, isTrue);
    });

    testWidgets('muted: no donation item, no strip', (
      WidgetTester tester,
    ) async {
      await userPreferences.muteDonationAsks(const Duration(days: 365));

      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm, _other],
      );

      expect(_ids(provider), <String>[_other.id]);
      expect(loaded(provider).donationStrip, isFalse);
    });

    testWidgets('a hidden strip leaves the other items alone', (
      WidgetTester tester,
    ) async {
      await userPreferences.hideDonationStrip(const Duration(days: 14));

      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm, _other],
      );

      expect(_ids(provider), <String>[_other.id]);
      expect(loaded(provider).donationStrip, isFalse);
    });

    testWidgets('a donation-only feed still has content: the strip', (
      WidgetTester tester,
    ) async {
      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm],
      );

      expect(_ids(provider), isEmpty);
      expect(loaded(provider).donationStrip, isTrue);
    });

    testWidgets('muted with only a donation item has no content', (
      WidgetTester tester,
    ) async {
      await userPreferences.muteDonationAsks(const Duration(days: 365));

      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm],
      );

      expect(provider.value, isA<ScanTagLineStateNoContent>());
    });

    testWidgets('the strip follows hiding without a feed reload', (
      WidgetTester tester,
    ) async {
      final ScanNewsFeedProvider provider = await _pumpProvider(
        tester,
        userPreferences,
        <AppNewsItem>[_donationReminderArm, _other],
      );
      expect(loaded(provider).donationStrip, isTrue);

      await userPreferences.hideDonationStrip(const Duration(days: 14));
      await tester.pump();

      expect(loaded(provider).donationStrip, isFalse);
    });
  });

  group('The home main card', () {
    testWidgets('home card side: the donation card, no strip', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[_donation]);

      expect(_titleFinder(_donation.title), findsOneWidget);
      expect(find.text(_stripHeadline), findsNothing);
    });

    testWidgets('reminder side: the strip instead of the donation card', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donationReminderArm,
        _other,
      ]);

      expect(find.text(_stripHeadline), findsOneWidget);
      expect(_titleFinder(_donation.title), findsNothing);
      expect(_titleFinder(_other.title), findsOneWidget);
    });

    testWidgets('the strip shows the campaign progress when the feed has it', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donationWithFigures,
      ]);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('the strip has no progress line without figures', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donationReminderArm,
      ]);

      expect(find.text(_stripHeadline), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('closing the strip hides it for 14 days and only it', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donationReminderArm,
        _other,
      ]);

      final DateTime before = DateTime.now();
      await tester.tap(find.byTooltip('Close'));
      await tester.pump();

      expect(find.text(_stripHeadline), findsNothing);
      expect(
        userPreferences.donationStripHiddenUntil!
            .difference(before.add(const Duration(days: 14)))
            .abs(),
        lessThan(const Duration(seconds: 5)),
      );
      expect(userPreferences.donationAsksMutedUntil, isNull);
      expect(_titleFinder(_other.title), findsOneWidget);
    });

    testWidgets('closing takes the days the feed declares', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        const AppNewsItem(
          id: 'donation_campaign_2026',
          title: 'title',
          message: 'message',
          url: 'https://world.openfoodfacts.org/',
          donationAbNewPercent: 100,
          donationStripHideDays: 7,
        ),
        _other,
      ]);

      final DateTime before = DateTime.now();
      await tester.tap(find.byTooltip('Close'));
      await tester.pump();

      expect(
        userPreferences.donationStripHiddenUntil!
            .difference(before.add(const Duration(days: 7)))
            .abs(),
        lessThan(const Duration(seconds: 5)),
      );
    });

    testWidgets('closing the only item leaves the expanded search card', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donationReminderArm,
      ]);
      expect(_searchCard(tester).expandedMode, isFalse);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();

      expect(_searchCard(tester).expandedMode, isTrue);
    });

    testWidgets('a muted donation-only feed expands the search card', (
      WidgetTester tester,
    ) async {
      await userPreferences.muteDonationAsks(const Duration(days: 365));
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[_donation]);

      expect(_searchCard(tester).expandedMode, isTrue);
    });

    for (final double scaler in <double>[1.3, 2.0]) {
      for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
        testWidgets('the strip at a text scale of $scaler in $theme', (
          WidgetTester tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = scaler;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final String previousTheme = userPreferences.currentTheme;
          addTearDown(() => userPreferences.setTheme(previousTheme));
          await userPreferences.setTheme(theme);

          await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
            _donationWithFigures,
          ]);

          expect(tester.takeException(), isNull);
          expect(find.text('30%'), findsOneWidget);
          expect(tester, meetsGuideline(textContrastGuideline));
          expect(tester, meetsGuideline(labeledTapTargetGuideline));
          // The guideline skips text merged into the strip's tap target.
          expect(
            _stripContrast(tester, _stripHeadline),
            greaterThanOrEqualTo(4.5),
          );
          expect(_stripContrast(tester, '30%'), greaterThanOrEqualTo(4.5));
        });
      }
    }
  });

  group('The home card after "I already donated"', () {
    testWidgets('is gone when the donation item was the only one', (
      WidgetTester tester,
    ) async {
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[_donation]);
      expect(_titleFinder(_donation.title), findsOneWidget);

      await _alreadyDonateFromSupport(tester);

      expect(find.byType(ScanNewsCard), findsNothing);
      expect(_titleFinder(_donation.title), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // The card keeps its rotation index across lists; with the donation item
    // first and the card already rotated to the second one, a shorter list
    // used to index past its end.
    testWidgets('shows the remaining item, even from the second slot', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Clicked items sort last, so the order is deterministic.
      await prefs.setStringList(_tagClicked, <String>[_other.id]);
      await _pumpMainCard(tester, userPreferences, <AppNewsItem>[
        _donation,
        _other,
      ]);
      expect(_titleFinder(_donation.title), findsOneWidget);

      await tester.pump(const Duration(minutes: 30));
      expect(_titleFinder(_other.title), findsOneWidget);

      await _alreadyDonateFromSupport(tester);

      expect(_titleFinder(_other.title), findsOneWidget);
      expect(_titleFinder(_donation.title), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
