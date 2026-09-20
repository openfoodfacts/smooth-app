import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
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
const String _tagDisplayed = 'taglineFeedNewsDisplayed';
const String _tagClicked = 'taglineFeedNewsClicked';

const String _alreadyDonated = 'I already donated';

const AppNewsItem _donation = AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
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

Future<void> _pumpBottomCard(
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
        child: const ScanBottomCard(dense: true),
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

Future<void> _alreadyDonateFromSupport(WidgetTester tester) async {
  final NavigatorState navigator = Navigator.of(
    tester.element(find.byType(ScanBottomCard)),
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

  group('The home card after "I already donated"', () {
    testWidgets('is gone when the donation item was the only one', (
      WidgetTester tester,
    ) async {
      await _pumpBottomCard(tester, userPreferences, <AppNewsItem>[_donation]);
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
      await _pumpBottomCard(tester, userPreferences, <AppNewsItem>[
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
